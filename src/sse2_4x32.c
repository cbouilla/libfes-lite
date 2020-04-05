#include "fes.h"

#define LANES 4
#define UNROLL 8

struct solution_t {
	u32 x;
	u32 mask;
};

struct context_t {
	int n;
	int m;

	u32 Fq[529 * LANES] __attribute__((aligned(32)));
	u32 Fl[33 * LANES] __attribute__((aligned(32)));

	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	struct solution_t local_buffer[(1 << UNROLL)];
	
	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK[LANES] = {0x000f, 0x00f0, 0x0f00, 0xf000};


static inline bool NEW_SOLUTION(struct context_t *context, u32 x, int lane)
{
	int k = context->size[lane];
	context->buffer[context->count * lane + k] = x;
	context->size[lane] = k + 1;
	return (context->size[lane] == context->count);
}

static inline bool FLUSH_BUFFER(struct context_t *context, struct solution_t * top, u64 i)
{	
	for (struct solution_t * bot = context->local_buffer; bot != top; bot++) {
		u32 x = to_gray(bot->x + i);
		u32 mask = bot->mask;
		#pragma GCC unroll 64
		for (int lane = 0; lane < LANES; lane++) 
			if ((mask & MASK[lane]) == MASK[lane])
				if (NEW_SOLUTION(context, x, lane))
					return true;
	}
	return false;
}

int feslite_sse2_enum_4x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < UNROLL || n > 32 || m != LANES)
		return FESLITE_EINVAL;

	struct context_t context;
	context.n = n;
	context.m = m;
	context.count = count;
	context.buffer = buffer;
	context.size = size;
	for (int i = 0; i < LANES; i++)
		context.size[i] = 0;

	setup32(n, LANES, Fq, Fl, context.Fq, context.Fl);

	ffs_reset(&context.ffs, n-UNROLL);
	int k1 = context.ffs.k1 + UNROLL;
	int k2 = context.ffs.k2 + UNROLL;

	u64 iterations = 1ul << (n - UNROLL);
	for (u64 j = 0; j < iterations; j++) {
		u64 alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + UNROLL;
		k2 = context.ffs.k2 + UNROLL;
		u64 beta = 1 + k1;
		u64 gamma = idxq(k1, k2);
		struct solution_t *top = feslite_sse2_asm_enum(context.Fq, context.Fl, 
		 	alpha, beta, gamma, context.local_buffer);
		if (FLUSH_BUFFER(&context, top, j << UNROLL))
			break;
	}
	return FESLITE_OK;
}