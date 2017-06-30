#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <getopt.h>

#include "feslite.h"
#include "monomials.h"

struct solution_t {
  uint32_t x;
  uint32_t mask;
};

struct context_t {
	int n;
	const uint32_t * const F_start;
	__m128i * F;
	struct solution_t buffer[8*512 + 32];
	size_t buffer_size;
	uint32_t candidates[32];
	size_t n_candidates;
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
	__m128i zero = _mm_setzero_si128();
	__m128i cmp = _mm_cmpeq_epi16(context->F[0], zero);
    	uint32_t mask = _mm_movemask_epi8(cmp);
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
	size_t n_good_cand = generic_eval_32(context->n, context->F_start, 16, 32, context->candidates,
			    context->n_candidates, context->solutions + context->n_solutions, context->max_solutions,
			    context->verbose);
	// fprintf(stderr, "FLUSH %zd candidates, %zd solutions\n", context->n_candidates, n_good_cand);
	context->max_solutions -= n_good_cand;
	context->n_solutions += n_good_cand;
	context->n_candidates = 0;
}


static inline void NEW_CANDIDATE(struct context_t *context, uint32_t i)
{
	// printf("candidate %08x\n", i);
	context->candidates[context->n_candidates] = i;
	context->n_candidates += 1;
	// printf("new candidate, now %zd candidates\n", context->n_candidates);
	if (context->n_candidates == 32)
		FLUSH_CANDIDATES(context);
}

/* Empty the Buffer. For each entry, check which half is correct,
   make it a Candidate. If there are 32 Candidates, batch-evaluate them. */
static inline void FLUSH_BUFFER(struct context_t *context)
{
	// printf("FLUSH BUFFER, size %zd, %zd candidates\n", context->buffer_size, context->n_candidates);
	for (size_t i = 0; i < context->buffer_size; i++) {
		uint32_t x = to_gray(context->buffer[i].x);
		if ((context->buffer[i].mask & 0x0003))
			NEW_CANDIDATE(context, x + 0 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x000c))
			NEW_CANDIDATE(context, x + 1 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x0030))
			NEW_CANDIDATE(context, x + 2 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x00c0))
			NEW_CANDIDATE(context, x + 3 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x0300))
			NEW_CANDIDATE(context, x + 4 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x0c00))
			NEW_CANDIDATE(context, x + 5 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0x3000))
			NEW_CANDIDATE(context, x + 6 * (1 << (context->n - 3)));
		if ((context->buffer[i].mask & 0xc000))
			NEW_CANDIDATE(context, x + 7 * (1 << (context->n - 3)));
	}
	context->buffer_size = 0;
}				

// generated with L = 9
size_t x86_64_enum_8x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose)
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
	size_t N = idx_1(n);
	__m128i F[N];
	context.F = F;

	for (size_t i = 0; i < N; i++)
		F[i] = _mm_set1_epi16(F_[i] & 0x0000ffff);
	
    	__m128i v0 = _mm_set_epi32(0xffffffff, 0xffffffff, 0x00000000, 0x00000000);
	__m128i v1 = _mm_set_epi32(0xffffffff, 0x00000000, 0xffffffff, 0x00000000);
	__m128i v2 = _mm_set_epi32(0xffff0000, 0xffff0000, 0xffff0000, 0xffff0000);
	 
	// the constant term is affected by [n-1]
	F[0] ^= F[idx_1(n - 1)] & v0;
	
	// [i] is affected by [i, n-1]
	for (int i = 0; i < n - 1; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 1)] & v0;

	// the constant term is affected by [n-2]
	F[0] ^= F[idx_1(n - 2)] & v1;
	
      	// [i] is affected by [i, n-2]
	for (int i = 0; i < n - 2; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 2)] & v1;
	
      	// the constant term is affected by [n-3]
	F[0] ^= F[idx_1(n - 3)] & v2;
	
      	// [i] is affected by [i, n-3]
	for (int i = 0; i < n - 3; i++)
		F[idx_1(i)] ^= F[idx_2(i, n - 3)] & v2;
	

	/******** compute "derivatives" */
	/* degree-1 terms are affected by degree-2 terms */
	for (int i = 1; i < n - 3; i++)
		F[idx_1(i)] ^= F[idx_2(i - 1, i)];

	if (verbose)
		printf("fes: initialisation = %" PRIu64 " cycles\n",
		       Now() - init_start_time);
	uint32_t enumeration_start_time = Now();

	// special case for i=0
	const uint32_t weight_0_start = 0;
	STEP_0(&context, 0);

	// from now on, hamming weight is >= 1
	for (int idx_0 = 0; idx_0 < n - 3; idx_0++) {

		// special case when i has hamming weight exactly 1
		const uint32_t weight_1_start = weight_0_start + (1ll << idx_0);
		STEP_1(&context, idx_1(idx_0), weight_1_start);

		// we are now inside the critical part where the hamming weight is known to be >= 2
		// Thus, there are no special cases from now on

		// Because of the last step, the current iteration counter is a multiple of 512 plus one
		// This loop sets it to `rolled_end`, which is a multiple of 512, if possible

		const uint32_t rolled_end =
		    weight_1_start + (1ll << min(9, idx_0));
		for (uint32_t i = 1 + weight_1_start; i < rolled_end; i++) {
			int pos = 0;
			/* k1 == rightmost 1 bit */
			uint32_t _i = i;
			while ((_i & 0x0001) == 0) {
				_i >>= 1;
				pos++;
			}
			const int k_1 = pos;
			/* k2 == second rightmost 1 bit */
			_i >>= 1;
			pos++;
			while ((_i & 0x0001) == 0) {
				_i >>= 1;
				pos++;
			}
			const int k_2 = pos;
			STEP_2(&context, idx_1(k_1), idx_2(k_1, k_2), i);
		}
		

		FLUSH_BUFFER(&context);
		if (context.max_solutions == 0)
			return context.n_solutions;

		// Here, the number of iterations to perform is (supposedly) sufficiently large
		// We will therefore unroll the loop 512 times

		// unrolled critical section where the hamming weight is >= 2
		for (uint32_t j = 512; j < (1ull << idx_0); j += 512) {
			const uint32_t i = j + weight_1_start;

			// ceci prend 75-200 cycles
			int pos = 0;
			uint32_t _i = i;
			while ((_i & 0x0001) == 0) {
				_i >>= 1;
				pos++;
			}
			const int k_1 = pos;
			_i >>= 1;
			pos++;
			while ((_i & 0x0001) == 0) {
				_i >>= 1;
				pos++;
			}
			const int k_2 = pos;
			const int alpha = idx_1(k_1);
			const int beta = idx_2(k_1, k_2);


			// les deux ensemble prennent 1500 cycles
			STEP_2(&context, alpha, beta, i);
			x86_64_asm_enum_8x16(F, alpha * sizeof(*F), context.buffer, &context.buffer_size, i);


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
