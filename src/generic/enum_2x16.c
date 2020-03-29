#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "ffs.h"
#include "monomials.h"

#define L 4
#define VERBOSE 0

/*
 * Enumerate and check equations [0:16]. 
 * Vectors that pass are "candidates".
 * when enough (==32) candidates have been accumulated, 
 * batch-eval them against equations [16:32].
 * Vectors that still pass are "solutions".
 */

struct solution_t {
	u32 x;
	u32 mask;
};

struct context_t {
	int n;
	int m;
	const u32 * Fq;
	const u32 * Fq_start;
	const u32 * Fl_start;
	u32 * Fl;

	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	int local_size;
	struct solution_t local_buffer[(1 << L)];

	/* candidates */
	u32 candidates[2][32];
	int n_candidates[2];
	bool overflow;

	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK0 = 0x0000fffful;
static const u32 MASK1 = 0xffff0000ul;

// tests the current value (corresponding to index), then step to the next one using a/b.
// this has to be as simple as possible... and as fast as possible
static inline void STEP_2(struct context_t *context, int a, int b, u32 index)
{
	u32 y = context->Fl[0];
	if (unlikely(((y & MASK0) == 0) || ((y & MASK1) == 0))) {
		context->local_buffer[context->local_size].mask = y;
		context->local_buffer[context->local_size].x = index;
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

	feslite_generic_eval_32(context->n, context->Fq_start, context->Fl_start + lane, 2, 
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
	// u32 y = feslite_naive_evaluation(context->n, context->Fq_start, context->Fl_start + lane, 2, x);
	// printf("# [DEBUG] candidate %08x in lane %d, with F[%d][%08x] = %08x\n", x, lane, lane, x, y);
	// assert((y & 0x0000ffff) == 0);

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
		u32 mask = context->local_buffer[i].mask;
		if ((mask & MASK0) == 0)             // lane 0
			NEW_CANDIDATE(context, x, 0);
		if ((mask & MASK1) == 0)             // lane 1
			NEW_CANDIDATE(context, x, 1);
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


void feslite_generic_enum_2x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < L || n > 32 || m != 2) {
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
	context.n_candidates[0] = 0;
	context.n_candidates[1] = 0;
	context.size[0] = 0;
	context.size[1] = 0;
	context.local_size = 0;
	context.overflow = false;
	context.Fq_start = Fq;
	context.Fl_start = Fl;

	u32 Fq_[529];
	u32 Fl_[33];
	int N = idxq(0, n);
	for (int i = 0; i < N; i++) {
		u32 a = Fq[i] & 0x0000ffff;
		Fq_[i] = a ^ (a << 16);
	}
	Fq_[idxq(0, n)] = 0;
	for (int i = 1; i < n; i++)
		Fq_[idxq(i, n)] = Fq_[idxq(i-1, i)];
	Fq_[idxq(n, n)] = 0;
	for (int i = 0; i < n + 1; i++) {
		u32 a = Fl[2 * i + 0] & 0x0000ffff;
		u32 b = Fl[2 * i + 1] & 0x0000ffff;
		Fl_[i] = a ^ (b << 16);
	}
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
	FLUSH_CANDIDATES(&context, 0);
	FLUSH_CANDIDATES(&context, 1);

	u64 enumeration_end_time = Now();
	if (VERBOSE)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n", 
			enumeration_end_time - enumeration_start_time);
}