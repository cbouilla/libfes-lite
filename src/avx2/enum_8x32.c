#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <getopt.h>
#include <immintrin.h>

#include "feslite.h"
#include "monomials.h"

#ifdef __AVX2__

// 0.19
#define L 9

struct solution_t {
  uint32_t x;
  uint32_t mask;
};

struct context_t {
	int n;
	const  uint32_t * const F_start;
	__m256i * F;
	struct solution_t buffer[512*8 + 32];
	size_t buffer_size;
	uint32_t *solutions;
	size_t n_solution_found;
	size_t max_solutions;
	size_t n_solutions;
	int verbose;
};

/* invoked when (at least) one lane is a solution. Both are pushed to the Buffer.
   Designed to be as quick as possible. */
static inline void CHECK_SOLUTION(struct context_t *context, uint32_t index)
{
	__m256i zero = _mm256_setzero_si256();
	__m256i cmp = _mm256_cmpeq_epi32(context->F[0], zero);
    	uint32_t mask = _mm256_movemask_epi8(cmp);
	if (unlikely(mask)) {
		context->buffer[context->buffer_size].mask = mask;
		context->buffer[context->buffer_size].x = index;
		context->buffer_size++;
	}
}

static inline void STEP_0(struct context_t *context, uint32_t index)
{
	CHECK_SOLUTION(context, index);
}

static inline void STEP_1(struct context_t *context, int a, uint32_t index)
{
	context->F[0] ^= context->F[a];
	STEP_0(context, index);
}

static inline void STEP_2(struct context_t *context, int a, int b, uint32_t index)
{
	context->F[a] ^= context->F[b];
	STEP_1(context, a, index);
}

/* Empty the Buffer. For each entry, check which half is correct,
   add it to the solutions. */
static inline void FLUSH_BUFFER(struct context_t *context)
{		
	for (size_t i = 0; i < context->buffer_size; i++) {
		uint32_t x = to_gray(context->buffer[i].x);
		for (size_t j = 0; j < 8; j++)
		if ((context->buffer[i].mask & (0x0000000f << (4 * j)))) {
			context->solutions[context->n_solutions++] = x + j * (1 << (context->n - 3));
			if (context->n_solutions == context->max_solutions)
				return;
		}
	}
	context->buffer_size = 0;
}				

// generated with L = 9
size_t feslite_avx2_enum_8x32(size_t n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    bool verbose)
{
	struct context_t context = { .F_start = F_ };
	context.n = n;
	context.solutions = solutions;
	context.n_solutions = 0;
	context.max_solutions = max_solutions;
	context.verbose = verbose;
	context.buffer_size = 0;
	// RESET_COUNTER(&context);

	uint64_t init_start_time = Now();
	size_t N = idx_1(n);
	__m256i F[N];
	context.F = F;

	for (size_t i = 0; i < N; i++)
		F[i] = _mm256_set1_epi32(F_[i]);

    	__m256i v0 = _mm256_set_epi32(0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0x00000000, 0x00000000);
	__m256i v1 = _mm256_set_epi32(0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000);
	__m256i v2 = _mm256_set_epi32(0xffffffff, 0x00000000, 0xffffffff, 0x00000000, 0xffffffff, 0x00000000, 0xffffffff, 0x00000000);
	 
	F[0] ^= F[idx_1(n - 1)] & v0;
	for (size_t i = 0; i < n - 1; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 1)] & v0;
	F[0] ^= F[idx_1(n - 2)] & v1;
	for (size_t i = 0; i < n - 2; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 2)] & v1;
	F[0] ^= F[idx_1(n - 3)] & v2;
	for (size_t i = 0; i < n - 3; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 3)] & v2;
	
	for (size_t i = 1; i < n - 3; i++)
		F[idx_1(i)] ^= F[idx_2(i - 1, i)];

	if (verbose)
		printf("fes: initialisation = %" PRIu64 " cycles\n",
		       Now() - init_start_time);

	uint64_t enumeration_start_time = Now();
	STEP_0(&context, 0);

	for (size_t idx_0 = 0; idx_0 < min(L, n - 3); idx_0++) {
		uint32_t w1 = (1 << idx_0);
		STEP_1(&context, idx_1(idx_0), w1);
		for (uint32_t i = w1 + 1; i < 2 * w1; i++) {
			int k1 = _tzcnt_u32(i);
			int alpha = idx_1(k1);
			int k2 = _tzcnt_u32(_blsr_u32(i));
			int beta = idx_2(k1, k2);
			STEP_2(&context, alpha, beta, i);
		}
		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;
	}


	for (size_t idx_0 = L; idx_0 < n - 3; idx_0++) {
		uint32_t w1 = (1 << idx_0);
		int alpha = idx_1(idx_0);
		STEP_1(&context, alpha, w1);
		feslite_avx2_asm_enum_8x32(F, (uint64_t) alpha * 32, context.buffer, &context.buffer_size, (uint64_t) w1);
		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;
		
		for (uint32_t j = 1 << L; j < w1; j += 1 << L) {
			uint32_t i = w1 + j;
			int k1 = _tzcnt_u32(i);
			int alpha = idx_1(k1);
			int k2 = _tzcnt_u32(_blsr_u32(i));
			int beta = idx_2(k1, k2);
			STEP_2(&context, alpha, beta, i);
          		feslite_avx2_asm_enum_8x32(F, (uint64_t) alpha * 32, context.buffer, &context.buffer_size, (uint64_t) i);
			FLUSH_BUFFER(&context);
			if (context.n_solutions == context.max_solutions)
				return context.n_solutions;
		}
	}

	uint64_t end_time = Now();
	if (verbose)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n",
		       end_time - enumeration_start_time);
	return context.n_solutions;
}
#endif