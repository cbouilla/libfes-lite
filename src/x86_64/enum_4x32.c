#include <stdio.h>

#include "fes.h"
#include "monomials.h"

#define L 9

// before : 0.38 cycles / candidates
// more unrolling : 0.38
// knuth trick in rolled : 0.38/0.39
// full treatment : 0.38...

struct solution_t {
  uint32_t x;
  uint32_t mask;
};

struct context_t {
	int n;
	const  uint32_t * const F_start;
	__m128i * F;
	struct solution_t buffer[512*4 + 32];
	size_t buffer_size;
	uint32_t *solutions;
	size_t n_solution_found;
	size_t max_solutions;
	size_t n_solutions;
	bool verbose;

	size_t focus[33];
	size_t stack[32];
	size_t sp;

	int k1;
	int k2;
};

static void RESET_COUNTER(struct context_t *context)
{
	context->sp = 1;
	context->stack[0] = -1;
	for (int j = 0; j <= context->n; j++)
		context->focus[j] = j;
}

/* this code implements constant-time computation of the number of 
   trailing zeroes (cf. TAOCP, vol 4) + constant-time evaluation of
   the position of the second rightmost set bit. */
static inline void UPDATE_COUNTER(struct context_t *context)
{
	size_t j = context->focus[0];
	context->focus[0] = 0;
	context->focus[j] = context->focus[j + 1];
	context->focus[j + 1] = j + 1;
	context->k1 = j;

	context->sp -= j;
	context->k2 = context->stack[context->sp - 1];
	context->stack[context->sp++] = j;
}

/* invoked when (at least) one lane is a solution. Both are pushed to the Buffer.
   Designed to be as quick as possible. */
static inline void CHECK_SOLUTION(struct context_t *context, uint32_t index)
{
	__m128i zero = _mm_setzero_si128();
	__m128i cmp = _mm_cmpeq_epi32(context->F[0], zero);
    	int mask = _mm_movemask_epi8(cmp);
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
	context->F[0] = _mm_xor_si128(context->F[0], context->F[a]);
	STEP_0(context, index);
}

static inline void STEP_2(struct context_t *context, int a, int b, uint32_t index)
{
	context->F[a] = _mm_xor_si128(context->F[a], context->F[b]);
	STEP_1(context, a, index);
}

/* Empty the Buffer. For each entry, check which half is correct,
   add it to the solutions. */
static inline void FLUSH_BUFFER(struct context_t *context)
{		
	for (size_t i = 0; i < context->buffer_size; i++) {
		uint32_t x = to_gray(context->buffer[i].x);
		if ((context->buffer[i].mask & 0x000f)) {
			context->solutions[context->n_solutions++] = x;
			if (context->n_solutions == context->max_solutions)
				return;
		}
		if ((context->buffer[i].mask & 0x00f0)) {
			context->solutions[context->n_solutions++] = x + (1 << (context->n - 2));
			if (context->n_solutions == context->max_solutions)
				return;
		}
		if ((context->buffer[i].mask & 0x0f00)) {
			context->solutions[context->n_solutions++] = x + 2 * (1 << (context->n - 2));
			if (context->n_solutions == context->max_solutions)
				return;
		}
		if ((context->buffer[i].mask & 0xf000)) {
			context->solutions[context->n_solutions++] = x + 3 * (1 << (context->n - 2));
			if (context->n_solutions == context->max_solutions)
				return;
		}
	}
	context->buffer_size = 0;
}				


// generated with L = 9
size_t feslite_x86_64_enum_4x32(size_t n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    bool verbose)
{
	uint64_t init_start_time = Now();

	struct context_t context = { .F_start = F_ };
	context.n = n;
	context.solutions = solutions;
	context.n_solutions = 0;
	context.max_solutions = max_solutions;
	context.verbose = verbose;
	context.buffer_size = 0;

	size_t N = idx_1(n);
	__m128i F[N];
	context.F = F;

	RESET_COUNTER(&context);

	for (size_t i = 0; i < N; i++)
		F[i] = _mm_set1_epi32(F_[i]);

	/******** 2-way "specialization" : remove the (n-1)-th variable */
    	__m128i v0 = _mm_set_epi32(0xffffffff, 0xffffffff, 0x00000000, 0x00000000);
	__m128i v1 = _mm_set_epi32(0xffffffff, 0x00000000, 0xffffffff, 0x00000000);
	 
	// the constant term is affected by [n-1]
	F[0] ^= F[idx_1(n-1)] & v0;
	

	// [i] is affected by [i, n-1]
	for (size_t i = 0; i < n - 1; i++)
		F[idx_1(i)] ^= F[idx_2(i, n-1)] & v0;
	
	// the constant term is affected by [n-2]
	F[0] ^= F[idx_1(n-2)] & v1;
	
      	// [i] is affected by [i, n-2]
	for (size_t i = 0; i < n - 2; i++)
		F[idx_1(i)] ^= F[idx_2(i, n-2)] & v1;
	
      
	/******** compute "derivatives" */
	/* degree-1 terms are affected by degree-2 terms */
	for (size_t i = 1; i < n; i++)
		F[idx_1(i)] ^= F[idx_2(i - 1, i)];

	if (verbose)
		printf("fes: initialisation = %" PRIu64 " cycles\n",
		       Now() - init_start_time);

	uint64_t enumeration_start_time = Now();
	STEP_0(&context, 0);

	for (size_t idx_0 = 0; idx_0 < min(L, n - 2); idx_0++) {
		const uint32_t w1 = (1 << idx_0);

		UPDATE_COUNTER(&context);
		STEP_1(&context, idx_1(context.k1), w1);
		for (uint32_t i = w1 + 1; i < 2 * w1; i++) {
			UPDATE_COUNTER(&context);
			STEP_2(&context, idx_1(context.k1), idx_2(context.k1, context.k2), i);
		}

		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;
	}

	RESET_COUNTER(&context);

	for (size_t idx_0 = L; idx_0 < n - 2; idx_0++) {
		const uint32_t w1 = (1 << idx_0);

		UPDATE_COUNTER(&context);
		int alpha = idx_1(idx_0);
		STEP_1(&context, alpha, w1);
		feslite_x86_64_asm_enum_4x32(F, alpha * sizeof(*F), context.buffer, &context.buffer_size, w1);
		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;

		for (uint32_t j = 1 << L; j < w1; j += 1 << L) {
			uint32_t i = w1 + j;
			UPDATE_COUNTER(&context);
			int alpha = idx_1(context.k1 + L);
			int beta = idx_2(context.k1 + L, context.k2 + L);

			STEP_2(&context, alpha, beta, i);
          		feslite_x86_64_asm_enum_4x32(F, alpha * sizeof(*F), context.buffer, &context.buffer_size, i);

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
