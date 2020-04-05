#include "fes.h"

#define L 4
#define LANES 2
#define VERBOSE 0

struct solution_t {
  u64 mask;
  u32 x;
};

struct context_t {
	int n;
	int m;
	u32 Fq[529*LANES] __attribute__((aligned(8)));;
	u32 Fl[33*LANES] __attribute__((aligned(8)));;
	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	int local_size;
	struct solution_t local_buffer[(1 << L)];
	
	/* counter */
	struct ffs_t ffs;
};

static const u64 MASK[LANES] = {0x00000000ffffffffull, 0xffffffff00000000ull};

// tests the current value (corresponding to index), then step to the next one using a/b.
static inline void STEP_2(struct context_t *context, int a, int b, u32 index)
{
	const u64 *Fq = (u64 *) context->Fq;
	u64 *Fl = (u64 *) context->Fl;
	u64 y = Fl[0];
	if (unlikely(((y & MASK[0]) == 0) || ((y & MASK[1]) == 0))) {
		context->local_buffer[context->local_size].mask = y;
		context->local_buffer[context->local_size].x = index;
		context->local_size++;
	}
	Fl[a] ^= Fq[b];
	Fl[0] ^= Fl[a];
}


static inline bool FLUSH_BUFFER(struct context_t *context)
{	
	for (int i = 0; i < context->local_size; i++) {	
		u32 x = to_gray(context->local_buffer[i].x);
		u64 mask = context->local_buffer[i].mask;
		// lane 0
		if ((mask & MASK[0]) == 0) {
			context->buffer[context->size[0]] = x;
			context->size[0]++;
			if (context->size[0] == context->count)
				return true;
		}
		// lane 1
		if ((mask & MASK[1]) == 0) {
			context->buffer[context->count + context->size[1]] = x;
			context->size[1]++;
			if (context->size[1] == context->count)
				return true;
		}
	}
	context->local_size = 0;
	return false;
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


int feslite_generic_enum_2x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
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
	
	for (int i = 0; i < LANES; i++)
	 	size[i] = 0;
	context.local_size = 0;

	setup32(n, LANES, Fq, Fl, context.Fq, context.Fl);

	ffs_reset(&context.ffs, n-L);
	int k1 = context.ffs.k1 + L;

	u32 iterations = 1ul << (n - L);
	for (u32 j = 0; j < iterations; j++) {
		u32 i = j << L;
		int alpha = idxq(0, k1);
		ffs_step(&context.ffs);	
		k1 = context.ffs.k1 + L;
		int beta = 1 + k1;
		int gamma = idxq(k1, context.ffs.k2 + L);
		UNROLLED_CHUNK(&context, alpha, beta, gamma, i);
		if (FLUSH_BUFFER(&context))
			break;
	}
	return FESLITE_OK;
}