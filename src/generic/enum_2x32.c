#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "ffs.h"
#include "monomials.h"

#define L 4
#define VERBOSE 0

struct solution_t {
  u64 mask;
  u32 x;
};

struct context_t {
	int n;
	int m;
	const u64 * Fq;
	u64 * Fl;
	int count;
	u32 *buffer;
	int *size;

	/* local solution buffer */
	int local_size;
	struct solution_t local_buffer[(1 << L)];
	
	/* counter */
	struct ffs_t ffs;
};

static const uint64_t LO_MASK = 0x00000000ffffffffull;
static const uint64_t HI_MASK = 0xffffffff00000000ull;

// tests the current value (corresponding to index), then step to the next one using a/b.
static inline void STEP_2(struct context_t *context, int a, int b, u32 index)
{
	if (unlikely(((context->Fl[0] & HI_MASK) == 0) | ((context->Fl[0] & LO_MASK) == 0))) {
		context->local_buffer[context->local_size].mask = context->Fl[0];
		context->local_buffer[context->local_size].x = index;
		context->local_size++;
	}
	context->Fl[a] ^= context->Fq[b];
	context->Fl[0] ^= context->Fl[a];
}


static inline bool FLUSH_BUFFER(struct context_t *context)
{	
	for (int i = 0; i < context->local_size; i++) {	
		u32 x = to_gray(context->local_buffer[i].x);
		// lane 0
		if ((context->local_buffer[i].mask & LO_MASK) == 0) {
			context->buffer[context->size[0]] = x;
			context->size[0]++;
			if (context->size[0] == context->count)
				return true;
		}
		// lane 1
		if ((context->local_buffer[i].mask & HI_MASK) == 0) {
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


void feslite_generic_enum_2x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n < L || n > 32 || m <= 0) {
		*size = -1;
		return;
	}
	assert(m == 2);

	uint64_t init_start_time = Now();

	struct context_t context;
	context.n = n;
	context.m = m;
	context.count = count;
	context.buffer = buffer;
	context.size = size;
	
	// for (int i = 0; i < m; i++)
	// 	size[i] = 0;
	size[0] = 0;
	size[1] = 0;
	context.local_size = 0;

	u64 Fq_[NQUAD];
	u64 Fl_[NLIN];
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		Fq_[i] = ((u64) Fq[i]) ^ (((u64) Fq[i]) << 32);
	Fq_[idxq(0, n)] = 0;
	for (int i = 1; i < n; i++)
		Fq_[idxq(i, n)] = Fq_[idxq(i-1, i)];
	Fq_[idxq(n, n)] = 0;
	// attention à la conversion de type
	for (int i = 0; i < n + 1; i++)
		Fl_[i] = Fl[2 * i] ^ (((u64) Fl[2 * i + 1]) << 32);
	context.Fq = Fq_;
	context.Fl = Fl_;

	if (VERBOSE)
		printf("fes: initialisation = %" PRIu64 " cycles\n", Now() - init_start_time);

	u64 enumeration_start_time = Now();

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

	u64 enumeration_end_time = Now();
	if (VERBOSE)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n", enumeration_end_time - enumeration_start_time);
}