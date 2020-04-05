#include "fes.h"

#define L 4
#define LANES 2

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
	u16 Fq[529*LANES] __attribute__((aligned(4)));
	u16 Fl[33*LANES] __attribute__((aligned(4)));
	const u32 * Fq_start;
	const u32 * Fl_start;
	
	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	int local_size;
	struct solution_t local_buffer[(1 << L)];

	/* candidates */
	u32 candidates[LANES][32];
	int n_candidates[LANES];
	bool overflow;

	/* counter */
	struct ffs_t ffs;
};

static const u32 MASK[LANES] = {0x0000ffff, 0xffff0000};

// tests the current value (corresponding to index), then step to the next one using a/b.
// this has to be as simple as possible... and as fast as possible
static inline void STEP_2(struct context_t *context, int a, int b, u32 index)
{
	const u32 *Fq = (u32 *) context->Fq;
	u32 *Fl = (u32 *) context->Fl;
	u32 y = Fl[0];
	if (unlikely(((y & MASK[0]) == 0) || ((y & MASK[1]) == 0))) {
		context->local_buffer[context->local_size].mask = y;
		context->local_buffer[context->local_size].x = index;
		context->local_size++;
	}
	Fl[a] ^= Fq[b];
	Fl[0] ^= Fl[a];
}


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


static inline bool FLUSH_BUFFER(struct context_t *context)
{	
	for (int i = 0; i < context->local_size; i++) {
		u32 x = to_gray(context->local_buffer[i].x);
		u32 mask = context->local_buffer[i].mask;
		if ((mask & MASK[0]) == 0)             // lane 0
			NEW_CANDIDATE(context, x, 0);
		if ((mask & MASK[1]) == 0)             // lane 1
			NEW_CANDIDATE(context, x, 1);
	}
	context->local_size = 0;
	return context->overflow;
}				


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


int feslite_generic_enum_2x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
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
	context.local_size = 0;
	context.overflow = false;
	context.Fq_start = Fq;
	context.Fl_start = Fl;

	setup16(n, LANES, Fq, Fl, context.Fq, context.Fl);

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
	return FESLITE_OK;
}