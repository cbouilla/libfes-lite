#include "fes.h"
#include "ffs.h"
#include "monomials.h"
#include <immintrin.h>

extern struct solution_t * feslite_x86_64_asm_enum_8x16(const __m128i * Fq, __m128i * Fl, 
	u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);

#define L 8
#define LANES 8
#define VERBOSE 0

struct solution_t {
	u32 x;
	u32 mask;
};

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
	struct solution_t local_buffer[(1 << L)];
	
	/* candidates */
	u32 candidates[LANES][32];
	int n_candidates[LANES];
	bool overflow;

	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK[LANES] = {0x0003, 0x000c, 0x0030, 0x00c0, 0x0300, 0x0c00, 0x3000, 0xc000};


/* batch-eval all the candidates */
static inline void FLUSH_CANDIDATES(struct context_t *context, int lane)
{
	int max_solutions = context->count - context->size[lane];

//	printf("# [DEBUG] FLUSH_CANDIDATES (lane %d) %d candidates, %d solutions, max_allowed=%d\n", 
//		lane, context->n_candidates[lane], context->size[lane], max_solutions);

	int k;
	u32 * outbuf = context->buffer + context->count * lane + context->size[lane];

	feslite_generic_eval_32(context->n, context->Fq_start, context->Fl_start + lane, LANES, 
				context->n_candidates[lane], context->candidates[lane], 
				max_solutions, outbuf, &k);

//	printf("# [DEBUG] FLUSH_CANDIDATES %d candidates passed for lane %d\n", k, lane);
	context->size[lane] += k;
	context->n_candidates[lane] = 0;
	if (context->size[lane] == context->count)
		context->overflow = true;
}


static inline void NEW_CANDIDATE(struct context_t *context, u32 x, int lane)
{
	// u32 y = feslite_naive_evaluation(context->n, context->Fq_start, context->Fl_start + lane, 4, x);
	// printf("# [DEBUG] candidate %08x in lane %d, with F[%d][%08x] = %08x\n", x, lane, lane, x, y);
	//assert(y == 0);

	int i = context->n_candidates[lane];
	context->candidates[lane][i] = x;
	context->n_candidates[lane] = i + 1;

	if (context->n_candidates[lane] == 32)
		FLUSH_CANDIDATES(context, lane);
}


static inline bool FLUSH_BUFFER(struct context_t *context, struct solution_t * top, u64 i)
{	
	// if (top != context->local_buffer)
	// 	printf("[DEBUG]  FLUSH_BUFFER %p -> %p (%ld solutions found)\n", 
	// 		context->local_buffer, top, top - context->local_buffer);
	for (struct solution_t * bot = context->local_buffer; bot != top; bot++) {
		u32 x = to_gray(bot->x + i);
		u32 mask = bot->mask;
		// printf("Got x = %08x / mask = %08x\n", x, mask);
		
		if (mask & MASK[0])             // lane 0
			NEW_CANDIDATE(context, x, 0);
		if (mask & MASK[1])             // lane 1
			NEW_CANDIDATE(context, x, 1);
		if (mask & MASK[2])             // lane 2
			NEW_CANDIDATE(context, x, 2);
		if (mask & MASK[3])             // lane 3
			NEW_CANDIDATE(context, x, 3);
		if (mask & MASK[4])             // lane 4
			NEW_CANDIDATE(context, x, 4);
		if (mask & MASK[5])             // lane 5
			NEW_CANDIDATE(context, x, 5);
		if (mask & MASK[6])             // lane 6
			NEW_CANDIDATE(context, x, 6);
		if (mask & MASK[7])             // lane 7
			NEW_CANDIDATE(context, x, 7);
	}
	return context->overflow;
}				



void feslite_x86_64_enum_8x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < L || n > 32 || m != LANES) {
		size[0] = -1;
		return;
	}

	struct context_t context;
	context.n = n;
	context.m = m;
	context.count = count;
	context.buffer = buffer;
	context.size = size;
	for (int i = 0; i < LANES; i++) {
		context.n_candidates[i] = 0;
		context.size[i] = 0;
	}
	context.overflow = false;
	context.Fq_start = Fq;
	context.Fl_start = Fl;

	__m128i Fq_[529];
	__m128i Fl_[33];

	// new
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		Fq_[i] = _mm_set1_epi16(Fq[i] & 0x0000ffff);
	Fq_[idxq(0, n)] = _mm_setzero_si128();
	for (int i = 1; i < n; i++)
		Fq_[idxq(i, n)] = Fq_[idxq(i-1, i)];
	Fq_[idxq(n, n)] = _mm_setzero_si128();
	for (int i = 0; i < n + 1; i++) {
		u32 a = Fl[8 * i + 0] & 0x0000ffff;
		u32 b = Fl[8 * i + 1] & 0x0000ffff;
		u32 c = Fl[8 * i + 2] & 0x0000ffff;
		u32 d = Fl[8 * i + 3] & 0x0000ffff;
		u32 e = Fl[8 * i + 4] & 0x0000ffff;
		u32 f = Fl[8 * i + 5] & 0x0000ffff;
		u32 g = Fl[8 * i + 6] & 0x0000ffff;
		u32 h = Fl[8 * i + 7] & 0x0000ffff;
		Fl_[i] = _mm_set_epi16(h, g, f, e, d, c, b, a);
	}
	context.Fq = Fq_;
	context.Fl = Fl_;

	// for (int i = 0; i <= idxq(n, n); i++) {
	// 	u32 *x = (u32 *) &context.Fq[i];
	// 	printf("Fq[%d] = %08x %08x %08x %08x\n", i, x[0], x[1], x[2], x[3]);
	// }
	// printf("\n");

	// for (int i = 0; i < n + 1; i++) {
	// 	u32 *x = (u32 *) &context.Fl[i];
	// 	printf("Fl[%d] = %08x %08x %08x %08x\n", i, x[0], x[1], x[2], x[3]);
	// }

	ffs_reset(&context.ffs, n-L);
	int k1 = context.ffs.k1 + L;
	int k2 = context.ffs.k2 + L;

	u64 iterations = 1ul << (n - L);
	for (u64 j = 0; j < iterations; j++) {
		u64 alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + L;
		k2 = context.ffs.k2 + L;
		u64 beta = 1 + k1;
		u64 gamma = idxq(k1, k2);
		//struct solution_t *top = UNROLLED_CHUNK(context.Fq, context.Fl, alpha, beta, gamma, context.local_buffer);
		struct solution_t *top = feslite_x86_64_asm_enum_8x16(context.Fq, context.Fl, 
		 	16*alpha, 16*beta, 16*gamma, context.local_buffer);
		//printf("j = %lx (alpha=%ld, beta=%ld, gamma=%ld)\n", j, alpha, beta, gamma);
		//for (int i = 0; i < n + 1; i++) {
		//	u32 *x = (u32 *) &context.Fl[i];
		//	printf("Fl[%d] = %08x %08x %08x %08x\n", i, x[0], x[1], x[2], x[3]);
		//}
		if (FLUSH_BUFFER(&context, top, j << L)) {
			//printf("Early abort at j=%ld\n", j);
			break;
		}
	}
	for (int i = 0; i < LANES; i++)
		FLUSH_CANDIDATES(&context, i);
}