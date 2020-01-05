#include <stdio.h>

#include "fes.h"
#include "monomials.h"

#ifdef __AVX2__
#include <immintrin.h>
#include <bmiintrin.h>

#define L 9

struct solution_t {
  uint32_t x;
  uint32_t mask;
};

struct context_t {
	int n;
	const  uint32_t * const F_start;
	__m256i * F;
	struct solution_t buffer[16*512 + 32];
	int64_t buffer_size;
	uint32_t candidates[32];
	int n_candidates;
	uint32_t *solutions;
	int n_solution_found;
	int max_solutions;
	int n_solutions;
	int verbose;
};

static inline void CHECK_SOLUTION(struct context_t *context, uint32_t index)
{
	__m256i zero = _mm256_setzero_si256();
	__m256i cmp = _mm256_cmpeq_epi16(context->F[0], zero);
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

/* batch-eval all the Candidates */
static inline void FLUSH_CANDIDATES(struct context_t *context)
{
	int n_good_cand = feslite_generic_eval_32(context->n, context->F_start, 16, 32, context->candidates,
			    context->n_candidates, context->solutions + context->n_solutions, context->max_solutions,
			    context->verbose);
	context->max_solutions -= n_good_cand;
	context->n_solutions += n_good_cand;
	context->n_candidates = 0;
}


static inline void NEW_CANDIDATE(struct context_t *context, uint32_t i)
{
	context->candidates[context->n_candidates] = i;
	context->n_candidates += 1;
	if (context->n_candidates == 32)
		FLUSH_CANDIDATES(context);
}

/* Empty the Buffer. For each entry, check which half is correct,
   add it to the solutions. */
static inline void FLUSH_BUFFER(struct context_t *context)
{		
	for (int i = 0; i < context->buffer_size; i++) {
		uint32_t x = to_gray(context->buffer[i].x);
		if ((context->buffer[i].mask & 0x00000003))
			NEW_CANDIDATE(context, x + 0 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x0000000c))
			NEW_CANDIDATE(context, x + 1 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00000030))
			NEW_CANDIDATE(context, x + 2 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x000000c0))
			NEW_CANDIDATE(context, x + 3 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00000300))
			NEW_CANDIDATE(context, x + 4 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00000c00))
			NEW_CANDIDATE(context, x + 5 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00003000))
			NEW_CANDIDATE(context, x + 6 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x0000c000))
			NEW_CANDIDATE(context, x + 7 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00030000))
			NEW_CANDIDATE(context, x + 8 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x000c0000))
			NEW_CANDIDATE(context, x + 9 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00300000))
			NEW_CANDIDATE(context, x + 10 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x00c00000))
			NEW_CANDIDATE(context, x + 11 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x03000000))
			NEW_CANDIDATE(context, x + 12 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x0c000000))
			NEW_CANDIDATE(context, x + 13 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0x30000000))
			NEW_CANDIDATE(context, x + 14 * (1 << (context->n - 4)));
		if ((context->buffer[i].mask & 0xc0000000))
			NEW_CANDIDATE(context, x + 15 * (1 << (context->n - 4)));
	}
	context->buffer_size = 0;
}				

// generated with L = 9
int feslite_avx2_enum_16x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, int max_solutions,
			    bool verbose)
{
	struct context_t context = { .F_start = F_ };
	context.n = n;
	context.solutions = solutions;
	context.n_solutions = 0;
	context.max_solutions = max_solutions;
	context.verbose = verbose;
	context.buffer_size = 0;
	context.n_candidates = 0;

	uint64_t init_start_time = Now();
	int N = idx_1(n);
	__m256i F[N];
	context.F = F;

	for (int i = 0; i < N; i++)
		F[i] = _mm256_set1_epi16(F_[i] & 0x0000ffff);

    	__m256i v0 = _mm256_set_epi32(0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0x00000000, 0x00000000);
	__m256i v1 = _mm256_set_epi32(0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000);
	__m256i v2 = _mm256_set_epi32(0xffffffff, 0x00000000, 0xffffffff, 0x00000000, 0xffffffff, 0x00000000, 0xffffffff, 0x00000000);
	__m256i v3 = _mm256_set_epi32(0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000);

	 
	F[0] ^= F[idx_1(n - 1)] & v0;
	for (int i = 0; i < n - 1; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 1)] & v0;
	F[0] ^= F[idx_1(n - 2)] & v1;
	for (int i = 0; i < n - 2; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 2)] & v1;
	F[0] ^= F[idx_1(n - 3)] & v2;
	for (int i = 0; i < n - 3; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 3)] & v2;
	F[0] ^= F[idx_1(n - 4)] & v3;
	for (int i = 0; i < n - 4; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 4)] & v3;
	
	for (int i = 1; i < n - 4; i++)
		F[idx_1(i)] ^= F[idx_2(i - 1, i)];

	if (verbose)
		printf("fes: initialisation = %" PRIu64 " cycles\n",
		       Now() - init_start_time);

	uint64_t enumeration_start_time = Now();
	STEP_0(&context, 0);

	for (int idx_0 = 0; idx_0 < min(L, n - 4); idx_0++) {
		uint32_t w1 = 1 << idx_0;
		STEP_1(&context, idx_1(idx_0), w1);
		for (uint32_t i = w1 + 1; i < 2 * w1; i++) {
			int k1 = _tzcnt_u32(i);
			int alpha = idx_1(k1);
			int k2 = _tzcnt_u32(_blsr_u32(i));
			int beta = idx_2(k1, k2);
			STEP_2(&context, alpha, beta, i);
		}
		FLUSH_BUFFER(&context);
		if (context.max_solutions == 0)
			return context.n_solutions;
	}

	if (verbose)
		printf("fes: enumeration[rolled] = %" PRIu64 " cycles\n",
		       Now() - enumeration_start_time);

	for (int idx_0 = L; idx_0 < n - 4; idx_0++) {
		uint32_t w1 = (1 << idx_0);
		int alpha = idx_1(idx_0);
		STEP_1(&context, alpha, w1);
		feslite_avx2_asm_enum_16x16(F, (uint64_t) alpha * sizeof(*F), context.buffer, &context.buffer_size, (uint64_t) w1);

		FLUSH_BUFFER(&context);
		if (context.max_solutions == 0)
			return context.n_solutions;

		for (uint32_t j = 1 << L; j < w1; j += 1 << L) {
			uint32_t i = w1 + j;
			int k1 = _tzcnt_u32(i);
			int alpha = idx_1(k1);
			int k2 = _tzcnt_u32(_blsr_u32(i));
			int beta = idx_2(k1, k2);
			STEP_2(&context, alpha, beta, i);
	    		feslite_avx2_asm_enum_16x16(F, (uint64_t) alpha * sizeof(*F), context.buffer, &context.buffer_size, (uint64_t) i);
			FLUSH_BUFFER(&context);
			if (context.max_solutions == 0)
				return context.n_solutions;

		}
	}
	FLUSH_CANDIDATES(&context);

	uint64_t end_time = Now();

	if (verbose)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n",
		       end_time - enumeration_start_time);


	return context.n_solutions;
}
#endif