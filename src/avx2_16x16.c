#include <stdio.h>
#include "fes.h"

#define L 8
#define LANES 16

struct solution_t {
	u32 x;
	u32 mask;
};

struct context_t {
	int n;
	int m;
	u16 Fq[561 * LANES] __attribute__((aligned(32)));
	u16 Fl[34 * LANES] __attribute__((aligned(32)));

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

/* batch-eval all the candidates */
static inline void FLUSH_CANDIDATES(struct context_t *context, int lane)
{
	int max_solutions = context->count - context->size[lane];
	int k;
	u32 * outbuf = context->buffer + context->count * lane + context->size[lane];
	feslite_generic_eval_32(context->n, context->Fq_start, context->Fl_start + lane, LANES, 
				context->n_candidates[lane], context->candidates[lane], 
				max_solutions, outbuf, &k);
	context->size[lane] += k;
	context->n_candidates[lane] = 0;
	if (context->size[lane] == context->count)
		context->overflow = true;
}


static inline void NEW_CANDIDATE(struct context_t *context, u32 x, int lane)
{
	int i = context->n_candidates[lane];
	context->candidates[lane][i] = x;
	context->n_candidates[lane] = i + 1;

	if (context->n_candidates[lane] == 32)
		FLUSH_CANDIDATES(context, lane);
}



static inline bool FLUSH_BUFFER(struct context_t *context, struct solution_t * top, u64 i)
{	
	for (struct solution_t * bot = context->local_buffer; bot != top; bot++) {
		u32 x = to_gray(bot->x + i);
		u32 mask = bot->mask;
		do {
			int i = __builtin_ctzl(mask);
			NEW_CANDIDATE(context, x, i / 2);	
			mask = mask & (mask - 1);
			mask = mask & (mask - 1);
		} while(mask);
	}
	return context->overflow;
}				

// static inline REWIND(int alpha, int k1, int gamma)
// {
// 	Fl[0] ^= gemv(n+1, D[k1], to_gray(i));
// 	/* update the derivatives */
// 	for (int i = 0; i < L; i++)
// 		Fl[1 + i] ^= Fq[alpha + i];
// 	for (int i = 0; i < L - 1; i++)
// 		Fl[1 + i] ^= Fq[idxq(i, L-1)];
// 	Fl[k1 + 1] ^= Fq[gamma];
// }

int feslite_avx2_enum_16x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < L || n > 32 || m != LANES)
		return FESLITE_EINVAL;

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

	setup16(n, LANES, Fq, Fl, context.Fq, context.Fl);
	
	ffs_reset(&context.ffs, n-L);
	int k1 = context.ffs.k1 + L;
	int k2 = context.ffs.k2 + L;

	// int npositive = 0;
	u64 iterations = 1ul << (n - L);
	for (u64 j = 0; j < iterations; j++) {
		u64 alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + L;
		k2 = context.ffs.k2 + L;
		u64 beta = 1 + k1;
		u64 gamma = idxq(k1, k2);
		//u32 mask = feslite_avx2_asm_enum_batch(context.Fq, context.Fl, alpha, beta, gamma);
		//if (mask) {
		//	// printf("FOUD MASK = %08x for i = %016lx\n", mask, j << L);
		//	npositive++;
		//	// REWIND();
		//	struct solution_t *top = feslite_avx2_asm_enum(context.Fq, context.Fl, 
		// 					alpha, beta, gamma, context.local_buffer);
		//	if (FLUSH_BUFFER(&context, top, j << L))
		//		break;
		//}
		struct solution_t *top = feslite_avx2_asm_enum(context.Fq, context.Fl, 
		 	alpha, beta, gamma, context.local_buffer);
		if (FLUSH_BUFFER(&context, top, j << L))
			break;
	}
	for (int i = 0; i < LANES; i++)
		FLUSH_CANDIDATES(&context, i);
	// printf("FOUD %d positive for %ld iterations\n", npositive, iterations);
	return FESLITE_OK;
}