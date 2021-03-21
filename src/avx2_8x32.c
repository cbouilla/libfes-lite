#include <assert.h>
#include <stdio.h>
#include "fes.h"

#define LANES 8
#define UNROLL 8
#define BATCH_MODE

struct solution_t {
	u32 x;
	u32 mask;
};

struct context_t {
	int n;
	int m;
	u32 Fq[561 * LANES] __attribute__((aligned(32)));
	u32 Fl[34 * LANES] __attribute__((aligned(32)));

	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	struct solution_t local_buffer[(1 << UNROLL)];
	
	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK[LANES] = { 0x0000000f, 0x000000f0, 0x00000f00, 0x0000f000,
                                 0x000f0000, 0x00f00000, 0x0f000000, 0xf0000000 };


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


static u32 gemv(int n, const u32 * M, u32 x)
{
	u32 r = M[0];
	for (int i = 0; i < n; i++)
		if (x & (1 << i))
			r ^= M[i + 1];
	return r;
}


static inline void REWIND(int n, const u32 *Fq, u32 *Fl, const u32 *original_Fl, const u32 (*D)[33], 
				int alpha, int beta, int gamma, u32 i)
{
	u32 mv = gemv(n+1, D[beta-1], to_gray(i));
	for (int i = 0; i < LANES; i++)
		Fl[i] ^= original_Fl[LANES*UNROLL + i] ^ original_Fl[LANES*beta + i] ^ mv;

	/* update the derivatives */
	for (int i = 0; i < LANES * UNROLL; i++)
		Fl[LANES + i] ^= Fq[LANES*alpha + i];

	for (int i = 0; i < LANES * (UNROLL - 1); i++)
		Fl[LANES + i] ^= Fq[LANES*idxq(0, UNROLL-1) + i];

	for (int i = 0; i < LANES; i++)
		Fl[LANES * beta + i] ^= Fq[LANES * gamma + i];
}


/* The Fq argument must be the output of setup32 */
void setup_derivative(int n, int L, const u32 *Fq, u32 (*D)[33])
{
	for (int k = L; k < n+1; k++) {
		// constant term
		D[k][0] = Fq[idxq(L-1, k)];

		for (int i = 0; i < L-1; i++)
			D[k][i+1] = Fq[idxq(i, L-1)];
		D[k][L] = 0;
		for (int i = L; i < n; i++)
			D[k][i+1] = Fq[idxq(L-1, i)];
		
		for (int i = 0; i < k; i++)
			D[k][i+1] ^= Fq[idxq(i, k)];
		for (int i = k+1; i < n; i++)
			D[k][i+1] ^= Fq[idxq(k, i)];
	}
}

int feslite_avx2_enum_8x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < UNROLL || n > 32 || m != LANES)
		return FESLITE_EINVAL;

	for (int i = 0; i < LANES; i++)
		assert(Fl[LANES*(n+1) + i] == 0);


	struct context_t context;
	context.n = n;
	context.m = m;
	context.count = count;
	context.buffer = buffer;
	context.size = size;
	for (int i = 0; i < LANES; i++)
		context.size[i] = 0;

	u32 Fq_tmp[561];
	setup32(n, LANES, Fq, Fl, Fq_tmp, context.Fl);
	broadcast32(n, LANES, Fq_tmp, context.Fq);
	
	/* precompute "derivatives" */
	u32 D[33][33];
	setup_derivative(n, UNROLL, Fq_tmp, D);

	ffs_reset(&context.ffs, n - UNROLL);
	int k1 = context.ffs.k1 + UNROLL;
	int k2 = context.ffs.k2 + UNROLL;

	u64 iterations = 1ul << (n - UNROLL);
	int n_positive = 0;
	for (u64 j = 0; j < iterations; j++) {
		u64 alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + UNROLL;
		k2 = context.ffs.k2 + UNROLL;
		u64 beta = 1 + k1;
		u64 gamma = idxq(k1, k2);
		u32 i = j << UNROLL;
		
#ifdef BATCH_MODE
		u32 mask = feslite_avx2_asm_enum_batch(context.Fq, context.Fl, alpha, beta, gamma);
		if (mask) {
			// printf("FOUD MASK = %08x for i = %016lx\n", mask, i);
			n_positive++;
			REWIND(n, context.Fq, context.Fl, Fl, D, alpha, beta, gamma, i);

			struct solution_t *top = feslite_avx2_asm_enum(context.Fq, context.Fl, 
		 					alpha, beta, gamma, context.local_buffer);
			if (FLUSH_BUFFER(&context, top, i))
				break;
		}
#else
		struct solution_t *top = feslite_avx2_asm_enum(context.Fq, context.Fl, 
							 	alpha, beta, gamma, context.local_buffer);
		if (FLUSH_BUFFER(&context, top, i))
		 	break;
#endif
	}
	printf("Found %d positive for %ld iterations\n", n_positive, iterations);
	return FESLITE_OK;
}