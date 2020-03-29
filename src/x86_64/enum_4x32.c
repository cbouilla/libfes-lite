#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "ffs.h"
#include "monomials.h"
#include <emmintrin.h>

#define L 4
#define VERBOSE 0

struct solution_t {
	u32 x;
	u32 mask;
};

/* deux options : __m128i dans Fq, ou bien u32 dans Fq... */

struct context_t {
	int n;
	int m;
	const __m128i * Fq;
	__m128i * Fl;

	const u32 * Fq_start;
	const u32 * Fl_start;

	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	int local_size;
	struct solution_t local_buffer[(1 << L)];

	/* candidates */
	u32 candidates[4][32];
	int n_candidates[4];
	bool overflow;

	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK0 = 0x000f;
static const u32 MASK1 = 0x00f0;
static const u32 MASK2 = 0x0f00;
static const u32 MASK3 = 0xf000;

// tests the current value (corresponding to index), then step to the next one using a/b.
// this has to be as simple as possible... and as fast as possible
static inline void STEP_2(struct context_t *context, int a, int b, u32 index)
{
	__m128i zero = _mm_setzero_si128();
	__m128i cmp = _mm_cmpeq_epi32(context->Fl[0], zero);
    	u32 mask = _mm_movemask_epi8(cmp);
	if (unlikely(mask)) {
		context->local_buffer[context->local_size].x = index;
		context->local_buffer[context->local_size].mask = mask;
		// u32 y[4];
		// _mm_store_si128((__m128i *) y, context->Fl[0]);
		// printf("got y = %08x %08x %08x %08x\n", y[0], y[1], y[2], y[3]);
		context->local_size++;
	}
	context->Fl[a] ^= context->Fq[b];
	context->Fl[0] ^= context->Fl[a];
}


/* batch-eval all the candidates */
static inline void FLUSH_CANDIDATES(struct context_t *context, int lane)
{
	int max_solutions = context->count - context->size[lane];

	//printf("# [DEBUG] FLUSH_CANDIDATES (lane %d) %d candidates, %d solutions, max_allowed=%d\n", 
	//	lane, context->n_candidates[lane], context->size[lane], max_solutions);

	int k;
	u32 * outbuf = context->buffer + context->count * lane + context->size[lane];

	feslite_generic_eval_32(context->n, context->Fq_start, context->Fl_start + lane, 4, 
				context->n_candidates[lane], context->candidates[lane], 
				max_solutions, outbuf, &k);

	// printf("# [DEBUG] FLUSH_CANDIDATES %d candidates passed for lane %d\n", k, lane);
	context->size[lane] += k;
	context->n_candidates[lane] = 0;
	if (context->size[lane] == context->count)
		context->overflow = true;
}


static inline void NEW_CANDIDATE(struct context_t *context, u32 x, int lane)
{
	//u32 y = feslite_naive_evaluation(context->n, context->Fq_start, context->Fl_start + lane, 4, x);
	//printf("# [DEBUG] candidate %08x in lane %d, with F[%d][%08x] = %08x\n", x, lane, lane, x, y);
	//assert(y == 0);

	int i = context->n_candidates[lane];
	context->candidates[lane][i] = x;
	context->n_candidates[lane] = i + 1;

	if (context->n_candidates[lane] == 32)
		FLUSH_CANDIDATES(context, lane);
}


static inline bool FLUSH_BUFFER(struct context_t *context)
{	
	for (int i = 0; i < context->local_size; i++) {
		u32 x = to_gray(context->local_buffer[i].x);
		u64 mask = context->local_buffer[i].mask;
		if (mask & MASK0)             // lane 0
			NEW_CANDIDATE(context, x, 0);
		if (mask & MASK1)             // lane 1
			NEW_CANDIDATE(context, x, 1);
		if (mask & MASK2)             // lane 2
			NEW_CANDIDATE(context, x, 2);
		if (mask & MASK3)             // lane 3
			NEW_CANDIDATE(context, x, 3);
	}
	context->local_size = 0;
	return context->overflow;
}				


/* 
 * k1,  k2  computed from i   --> alpha == idxq(0, k1). 
 * k1', k2' computed from i+1 --> beta == 1 + k1', gamma = idxq(k1', k2')
 */
static inline void UNROLLED_CHUNK(struct context_t *context, int alpha, int beta, int gamma, u32 i)
{
	// printf("CHUNK with i = %x, alpha=%d, beta=%d, gamma=%d\n", i, alpha, beta, gamma);
	STEP_2(context, 1, alpha + 0, i + 0);
	STEP_2(context, 2, alpha + 1, i + 1);
	STEP_2(context, 1, 0, i + 2);
	STEP_2(context, 3, alpha + 2, i + 3);
	STEP_2(context, 1, 1, i + 4);
	STEP_2(context, 2, 2, i + 5);
	STEP_2(context, 1, 0, i + 6);
	STEP_2(context, 4, alpha + 3, i + 7);
	STEP_2(context, 1, 3, i + 8);
	STEP_2(context, 2, 4, i + 9);
	STEP_2(context, 1, 0, i + 10);
	STEP_2(context, 3, 5, i + 11);
	STEP_2(context, 1, 1, i + 12);
	STEP_2(context, 2, 2, i + 13);
	STEP_2(context, 1, 0, i + 14);
	STEP_2(context, beta, gamma, i + 15);
}


void feslite_x86_64_enum_4x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < L || n > 32 || m != 4) {
		size[0] = -1;
		return;
	}
	u64 init_start_time = Now();

	struct context_t context;
	context.n = n;
	context.m = m;
	context.count = count;
	context.buffer = buffer;
	context.size = size;
	for (int i = 0; i < 4; i++) {
		context.n_candidates[i] = 0;
		context.size[i] = 0;
	}
	context.local_size = 0;
	context.overflow = false;
	context.Fq_start = Fq;
	context.Fl_start = Fl;

	__m128i Fq_[529];
	__m128i Fl_[33];
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		Fq_[i] = _mm_set1_epi32(Fq[i]);
	Fq_[idxq(0, n)] = _mm_setzero_si128();
	for (int i = 1; i < n; i++)
		Fq_[idxq(i, n)] = Fq_[idxq(i-1, i)];
	Fq_[idxq(n, n)] = _mm_setzero_si128();
	for (int i = 0; i < n + 1; i++)
		Fl_[i] = _mm_set_epi32(Fl[4*i + 3], Fl[4*i + 2], Fl[4*i + 1],  Fl[4*i + 0]);
	context.Fq = Fq_;
	context.Fl = Fl_;

	if (VERBOSE)
		printf("fes: initialisation = %" PRIu64 " cycles\n", Now() - init_start_time);

	u64 enumeration_start_time = Now();

	ffs_reset(&context.ffs, n-L);
	int k1 = context.ffs.k1 + L;
	int k2 = context.ffs.k2 + L;

	u32 iterations = 1ul << (n - L);
	for (u32 j = 0; j < iterations; j++) {
		u32 i = j << L;
		int alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + L;
		k2 = context.ffs.k2 + L;
		int beta = 1 + k1;
		int gamma = idxq(k1, k2);
		UNROLLED_CHUNK(&context, alpha, beta, gamma, i);
		if (FLUSH_BUFFER(&context))
			break;
	}
	for (int i = 0; i < 4; i++)
		FLUSH_CANDIDATES(&context, i);
	
	u64 enumeration_end_time = Now();
	if (VERBOSE)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n", 
			enumeration_end_time - enumeration_start_time);
}