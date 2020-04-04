#include <stdio.h>
#include <inttypes.h>
#include "fes.h"

#define L 9
#define LANES 64

struct solution_t {
	u64 x;
	u64 mask;
};

struct context_t {
	int n;
	int m;
	u16 Fq[529 * 32] __attribute__((aligned(64)));
	u16 Fl[33 * 64] __attribute__((aligned(64)));

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

static const u64 MASK[LANES] = {
	0x0000000000000001, 0x0000000000000002, 0x0000000000000004, 0x0000000000000008,
	0x0000000000000010, 0x0000000000000020, 0x0000000000000040, 0x0000000000000080,
	0x0000000000000100, 0x0000000000000200, 0x0000000000000400, 0x0000000000000800,
	0x0000000000001000, 0x0000000000002000, 0x0000000000004000, 0x0000000000008000,
	0x0000000000010000, 0x0000000000020000, 0x0000000000040000, 0x0000000000080000,
	0x0000000000100000, 0x0000000000200000, 0x0000000000400000, 0x0000000000800000,
	0x0000000001000000, 0x0000000002000000, 0x0000000004000000, 0x0000000008000000,
	0x0000000010000000, 0x0000000020000000, 0x0000000040000000, 0x0000000080000000,
	0x0000000100000000, 0x0000000200000000, 0x0000000400000000, 0x0000000800000000,
	0x0000001000000000, 0x0000002000000000, 0x0000004000000000, 0x0000008000000000,
	0x0000010000000000, 0x0000020000000000, 0x0000040000000000, 0x0000080000000000,
	0x0000100000000000, 0x0000200000000000, 0x0000400000000000, 0x0000800000000000,
	0x0001000000000000, 0x0002000000000000, 0x0004000000000000, 0x0008000000000000,
	0x0010000000000000, 0x0020000000000000, 0x0040000000000000, 0x0080000000000000,
	0x0100000000000000, 0x0200000000000000, 0x0400000000000000, 0x0800000000000000,
	0x1000000000000000, 0x2000000000000000, 0x4000000000000000, 0x8000000000000000
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
		u64 mask = bot->mask;
		// possible optimization : split in two or in four.
		#pragma GCC unroll 128
		for (int i = 0; i < LANES; i++)
			if (mask & MASK[i])
				NEW_CANDIDATE(context, x, i);
	}
	return context->overflow;
}				



void feslite_avx512bw_enum_64x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
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

	setup16x2(n, 32, Fq, Fl, context.Fq, context.Fl);
	
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
		struct solution_t *top = feslite_avx512x2bw_asm_enum(context.Fq, context.Fl, 
		 	alpha, beta, gamma, context.local_buffer);
		if (FLUSH_BUFFER(&context, top, j << L))
			break;
	}
	for (int i = 0; i < LANES; i++)
		FLUSH_CANDIDATES(&context, i);
}