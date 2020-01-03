#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>

#include "feslite.h"
#include "monomials.h"

struct solution_t {
  uint32_t x;
  uint64_t mask;
};

struct context_t {
	int n;
	const uint32_t * const F_start;
	uint64_t * F;
	struct solution_t buffer[4*512 + 32];
	size_t buffer_size;
	uint32_t candidates[32];
	size_t n_candidates;
	uint32_t *solutions;
	size_t n_solution_found;
	size_t max_solutions;
	size_t n_solutions;
	int verbose;
};

/* invoked when (at least) one half is a solution. Both are pushed to the Buffer.
   Designed to be as quick as possible. */
static inline void CHECK_SOLUTION(struct context_t *context, uint32_t index)
{
	// if (unlikely((context->F[0] - 0x00010001) & (~context->F[0]) & 0x80008000)) {
	if (unlikely(((context->F[0] & 0x00000000ffff0000ull) == 0) || ((context->F[0] & 0x000000000000ffffull) == 0) 
		  || ((context->F[0] & 0xffff000000000000ull) == 0) || ((context->F[0] & 0x0000ffff00000000ull) == 0))) {
		//printf("candidate scontext->F[0]olution %08x or %08x (mask = %08x)\n", to_gray(index), to_gray(index) ^ (1 << (context->n)), context->F[0]);
		context->buffer[context->buffer_size].mask = context->F[0];
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
		if ((context->buffer[i].mask & 0x000000000000ffff) == 0)
			NEW_CANDIDATE(context, x + 0 * (1 << (context->n - 2)));
		if ((context->buffer[i].mask & 0x00000000ffff0000) == 0)
			NEW_CANDIDATE(context, x + 1 * (1 << (context->n - 2)));
		if ((context->buffer[i].mask & 0x0000ffff00000000) == 0)
			NEW_CANDIDATE(context, x + 2 * (1 << (context->n - 2)));
		if ((context->buffer[i].mask & 0xffff000000000000) == 0)
			NEW_CANDIDATE(context, x + 3 * (1 << (context->n - 2)));
	}
	context->buffer_size = 0;
}				

// generated with L = 9
size_t generic_enum_4x16(int n, const uint32_t * const F_,
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
	uint16_t F_16[4 * N];
	uint64_t *F = (uint64_t *) F_16;
	context.F = F;

	for (size_t i = 0; i < N; i++) {
		uint32_t low = F_[i] & 0x0000ffff;
		F_16[4 * i + 0] = low;
		F_16[4 * i + 1] = low;
		F_16[4 * i + 2] = low;
		F_16[4 * i + 3] = low;

	}

	/******** 2-way "specialization" : remove [n-1] and [n-2] */
	uint64_t v0 = 0xffffffff00000000ull;
	uint64_t v1 = 0xffff0000ffff0000ull;
	 
	// the constant term is affected by [n-1]
	F[0] ^= F[idx_1(n-1)] & v0;
	
	// the constant term is affected by [n-2]
	F[0] ^= F[idx_1(n-2)] & v1;
	
	// the constant term is affected by [n-2,n-1]
	F[0] ^= F[idx_2(n-2,n-1)] & v0 & v1;
	
	// [i] is affected by [i, n-1]
	for (size_t i = 0; i < n - 2; i++)
		F[idx_1(i)] ^= F[idx_2(i, n-1)] & v0;
	
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

	// special case for i=0
	const uint64_t weight_0_start = 0;
	STEP_0(&context, 0);

	// from now on, hamming weight is >= 1
	for (int idx_0 = 0; idx_0 < n - 2; idx_0++) {

		// special case when i has hamming weight exactly 1
		const uint64_t weight_1_start = weight_0_start + (1ll << idx_0);
		STEP_1(&context, idx_1(idx_0), weight_1_start);

		// we are now inside the critical part where the hamming weight is known to be >= 2
		// Thus, there are no special cases from now on

		// Because of the last step, the current iteration counter is a multiple of 512 plus one
		// This loop sets it to `rolled_end`, which is a multiple of 512, if possible

		const uint64_t rolled_end =
		    weight_1_start + (1ll << min(9, idx_0));
		for (uint64_t i = 1 + weight_1_start; i < rolled_end; i++) {
			int pos = 0;
			/* k1 == rightmost 1 bit */
			uint64_t _i = i;
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
		for (uint64_t j = 512; j < (1ull << idx_0); j += 512) {
			const uint64_t i = j + weight_1_start;
			// printf("testing idx %08x : F[0] = %08x\n", i, F[0]);

			int pos = 0;
			uint64_t _i = i;
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

			STEP_2(&context, 0 + alpha, 0 + beta, i + 0);
			STEP_2(&context, 1, 1 + alpha, i + 1);
			STEP_2(&context, 2, 2 + alpha, i + 2);
			STEP_2(&context, 1, 3, i + 3);
			STEP_2(&context, 4, 3 + alpha, i + 4);
			STEP_2(&context, 1, 5, i + 5);
			STEP_2(&context, 2, 6, i + 6);
			STEP_2(&context, 1, 3, i + 7);
			STEP_2(&context, 7, 4 + alpha, i + 8);
			STEP_2(&context, 1, 8, i + 9);
			STEP_2(&context, 2, 9, i + 10);
			STEP_2(&context, 1, 3, i + 11);
			STEP_2(&context, 4, 10, i + 12);
			STEP_2(&context, 1, 5, i + 13);
			STEP_2(&context, 2, 6, i + 14);
			STEP_2(&context, 1, 3, i + 15);
			STEP_2(&context, 11, 5 + alpha, i + 16);
			STEP_2(&context, 1, 12, i + 17);
			STEP_2(&context, 2, 13, i + 18);
			STEP_2(&context, 1, 3, i + 19);
			STEP_2(&context, 4, 14, i + 20);
			STEP_2(&context, 1, 5, i + 21);
			STEP_2(&context, 2, 6, i + 22);
			STEP_2(&context, 1, 3, i + 23);
			STEP_2(&context, 7, 15, i + 24);
			STEP_2(&context, 1, 8, i + 25);
			STEP_2(&context, 2, 9, i + 26);
			STEP_2(&context, 1, 3, i + 27);
			STEP_2(&context, 4, 10, i + 28);
			STEP_2(&context, 1, 5, i + 29);
			STEP_2(&context, 2, 6, i + 30);
			STEP_2(&context, 1, 3, i + 31);
			STEP_2(&context, 16, 6 + alpha, i + 32);
			STEP_2(&context, 1, 17, i + 33);
			STEP_2(&context, 2, 18, i + 34);
			STEP_2(&context, 1, 3, i + 35);
			STEP_2(&context, 4, 19, i + 36);
			STEP_2(&context, 1, 5, i + 37);
			STEP_2(&context, 2, 6, i + 38);
			STEP_2(&context, 1, 3, i + 39);
			STEP_2(&context, 7, 20, i + 40);
			STEP_2(&context, 1, 8, i + 41);
			STEP_2(&context, 2, 9, i + 42);
			STEP_2(&context, 1, 3, i + 43);
			STEP_2(&context, 4, 10, i + 44);
			STEP_2(&context, 1, 5, i + 45);
			STEP_2(&context, 2, 6, i + 46);
			STEP_2(&context, 1, 3, i + 47);
			STEP_2(&context, 11, 21, i + 48);
			STEP_2(&context, 1, 12, i + 49);
			STEP_2(&context, 2, 13, i + 50);
			STEP_2(&context, 1, 3, i + 51);
			STEP_2(&context, 4, 14, i + 52);
			STEP_2(&context, 1, 5, i + 53);
			STEP_2(&context, 2, 6, i + 54);
			STEP_2(&context, 1, 3, i + 55);
			STEP_2(&context, 7, 15, i + 56);
			STEP_2(&context, 1, 8, i + 57);
			STEP_2(&context, 2, 9, i + 58);
			STEP_2(&context, 1, 3, i + 59);
			STEP_2(&context, 4, 10, i + 60);
			STEP_2(&context, 1, 5, i + 61);
			STEP_2(&context, 2, 6, i + 62);
			STEP_2(&context, 1, 3, i + 63);
			STEP_2(&context, 22, 7 + alpha, i + 64);
			STEP_2(&context, 1, 23, i + 65);
			STEP_2(&context, 2, 24, i + 66);
			STEP_2(&context, 1, 3, i + 67);
			STEP_2(&context, 4, 25, i + 68);
			STEP_2(&context, 1, 5, i + 69);
			STEP_2(&context, 2, 6, i + 70);
			STEP_2(&context, 1, 3, i + 71);
			STEP_2(&context, 7, 26, i + 72);
			STEP_2(&context, 1, 8, i + 73);
			STEP_2(&context, 2, 9, i + 74);
			STEP_2(&context, 1, 3, i + 75);
			STEP_2(&context, 4, 10, i + 76);
			STEP_2(&context, 1, 5, i + 77);
			STEP_2(&context, 2, 6, i + 78);
			STEP_2(&context, 1, 3, i + 79);
			STEP_2(&context, 11, 27, i + 80);
			STEP_2(&context, 1, 12, i + 81);
			STEP_2(&context, 2, 13, i + 82);
			STEP_2(&context, 1, 3, i + 83);
			STEP_2(&context, 4, 14, i + 84);
			STEP_2(&context, 1, 5, i + 85);
			STEP_2(&context, 2, 6, i + 86);
			STEP_2(&context, 1, 3, i + 87);
			STEP_2(&context, 7, 15, i + 88);
			STEP_2(&context, 1, 8, i + 89);
			STEP_2(&context, 2, 9, i + 90);
			STEP_2(&context, 1, 3, i + 91);
			STEP_2(&context, 4, 10, i + 92);
			STEP_2(&context, 1, 5, i + 93);
			STEP_2(&context, 2, 6, i + 94);
			STEP_2(&context, 1, 3, i + 95);
			STEP_2(&context, 16, 28, i + 96);
			STEP_2(&context, 1, 17, i + 97);
			STEP_2(&context, 2, 18, i + 98);
			STEP_2(&context, 1, 3, i + 99);
			STEP_2(&context, 4, 19, i + 100);
			STEP_2(&context, 1, 5, i + 101);
			STEP_2(&context, 2, 6, i + 102);
			STEP_2(&context, 1, 3, i + 103);
			STEP_2(&context, 7, 20, i + 104);
			STEP_2(&context, 1, 8, i + 105);
			STEP_2(&context, 2, 9, i + 106);
			STEP_2(&context, 1, 3, i + 107);
			STEP_2(&context, 4, 10, i + 108);
			STEP_2(&context, 1, 5, i + 109);
			STEP_2(&context, 2, 6, i + 110);
			STEP_2(&context, 1, 3, i + 111);
			STEP_2(&context, 11, 21, i + 112);
			STEP_2(&context, 1, 12, i + 113);
			STEP_2(&context, 2, 13, i + 114);
			STEP_2(&context, 1, 3, i + 115);
			STEP_2(&context, 4, 14, i + 116);
			STEP_2(&context, 1, 5, i + 117);
			STEP_2(&context, 2, 6, i + 118);
			STEP_2(&context, 1, 3, i + 119);
			STEP_2(&context, 7, 15, i + 120);
			STEP_2(&context, 1, 8, i + 121);
			STEP_2(&context, 2, 9, i + 122);
			STEP_2(&context, 1, 3, i + 123);
			STEP_2(&context, 4, 10, i + 124);
			STEP_2(&context, 1, 5, i + 125);
			STEP_2(&context, 2, 6, i + 126);
			STEP_2(&context, 1, 3, i + 127);
			STEP_2(&context, 29, 8 + alpha, i + 128);
			STEP_2(&context, 1, 30, i + 129);
			STEP_2(&context, 2, 31, i + 130);
			STEP_2(&context, 1, 3, i + 131);
			STEP_2(&context, 4, 32, i + 132);
			STEP_2(&context, 1, 5, i + 133);
			STEP_2(&context, 2, 6, i + 134);
			STEP_2(&context, 1, 3, i + 135);
			STEP_2(&context, 7, 33, i + 136);
			STEP_2(&context, 1, 8, i + 137);
			STEP_2(&context, 2, 9, i + 138);
			STEP_2(&context, 1, 3, i + 139);
			STEP_2(&context, 4, 10, i + 140);
			STEP_2(&context, 1, 5, i + 141);
			STEP_2(&context, 2, 6, i + 142);
			STEP_2(&context, 1, 3, i + 143);
			STEP_2(&context, 11, 34, i + 144);
			STEP_2(&context, 1, 12, i + 145);
			STEP_2(&context, 2, 13, i + 146);
			STEP_2(&context, 1, 3, i + 147);
			STEP_2(&context, 4, 14, i + 148);
			STEP_2(&context, 1, 5, i + 149);
			STEP_2(&context, 2, 6, i + 150);
			STEP_2(&context, 1, 3, i + 151);
			STEP_2(&context, 7, 15, i + 152);
			STEP_2(&context, 1, 8, i + 153);
			STEP_2(&context, 2, 9, i + 154);
			STEP_2(&context, 1, 3, i + 155);
			STEP_2(&context, 4, 10, i + 156);
			STEP_2(&context, 1, 5, i + 157);
			STEP_2(&context, 2, 6, i + 158);
			STEP_2(&context, 1, 3, i + 159);
			STEP_2(&context, 16, 35, i + 160);
			STEP_2(&context, 1, 17, i + 161);
			STEP_2(&context, 2, 18, i + 162);
			STEP_2(&context, 1, 3, i + 163);
			STEP_2(&context, 4, 19, i + 164);
			STEP_2(&context, 1, 5, i + 165);
			STEP_2(&context, 2, 6, i + 166);
			STEP_2(&context, 1, 3, i + 167);
			STEP_2(&context, 7, 20, i + 168);
			STEP_2(&context, 1, 8, i + 169);
			STEP_2(&context, 2, 9, i + 170);
			STEP_2(&context, 1, 3, i + 171);
			STEP_2(&context, 4, 10, i + 172);
			STEP_2(&context, 1, 5, i + 173);
			STEP_2(&context, 2, 6, i + 174);
			STEP_2(&context, 1, 3, i + 175);
			STEP_2(&context, 11, 21, i + 176);
			STEP_2(&context, 1, 12, i + 177);
			STEP_2(&context, 2, 13, i + 178);
			STEP_2(&context, 1, 3, i + 179);
			STEP_2(&context, 4, 14, i + 180);
			STEP_2(&context, 1, 5, i + 181);
			STEP_2(&context, 2, 6, i + 182);
			STEP_2(&context, 1, 3, i + 183);
			STEP_2(&context, 7, 15, i + 184);
			STEP_2(&context, 1, 8, i + 185);
			STEP_2(&context, 2, 9, i + 186);
			STEP_2(&context, 1, 3, i + 187);
			STEP_2(&context, 4, 10, i + 188);
			STEP_2(&context, 1, 5, i + 189);
			STEP_2(&context, 2, 6, i + 190);
			STEP_2(&context, 1, 3, i + 191);
			STEP_2(&context, 22, 36, i + 192);
			STEP_2(&context, 1, 23, i + 193);
			STEP_2(&context, 2, 24, i + 194);
			STEP_2(&context, 1, 3, i + 195);
			STEP_2(&context, 4, 25, i + 196);
			STEP_2(&context, 1, 5, i + 197);
			STEP_2(&context, 2, 6, i + 198);
			STEP_2(&context, 1, 3, i + 199);
			STEP_2(&context, 7, 26, i + 200);
			STEP_2(&context, 1, 8, i + 201);
			STEP_2(&context, 2, 9, i + 202);
			STEP_2(&context, 1, 3, i + 203);
			STEP_2(&context, 4, 10, i + 204);
			STEP_2(&context, 1, 5, i + 205);
			STEP_2(&context, 2, 6, i + 206);
			STEP_2(&context, 1, 3, i + 207);
			STEP_2(&context, 11, 27, i + 208);
			STEP_2(&context, 1, 12, i + 209);
			STEP_2(&context, 2, 13, i + 210);
			STEP_2(&context, 1, 3, i + 211);
			STEP_2(&context, 4, 14, i + 212);
			STEP_2(&context, 1, 5, i + 213);
			STEP_2(&context, 2, 6, i + 214);
			STEP_2(&context, 1, 3, i + 215);
			STEP_2(&context, 7, 15, i + 216);
			STEP_2(&context, 1, 8, i + 217);
			STEP_2(&context, 2, 9, i + 218);
			STEP_2(&context, 1, 3, i + 219);
			STEP_2(&context, 4, 10, i + 220);
			STEP_2(&context, 1, 5, i + 221);
			STEP_2(&context, 2, 6, i + 222);
			STEP_2(&context, 1, 3, i + 223);
			STEP_2(&context, 16, 28, i + 224);
			STEP_2(&context, 1, 17, i + 225);
			STEP_2(&context, 2, 18, i + 226);
			STEP_2(&context, 1, 3, i + 227);
			STEP_2(&context, 4, 19, i + 228);
			STEP_2(&context, 1, 5, i + 229);
			STEP_2(&context, 2, 6, i + 230);
			STEP_2(&context, 1, 3, i + 231);
			STEP_2(&context, 7, 20, i + 232);
			STEP_2(&context, 1, 8, i + 233);
			STEP_2(&context, 2, 9, i + 234);
			STEP_2(&context, 1, 3, i + 235);
			STEP_2(&context, 4, 10, i + 236);
			STEP_2(&context, 1, 5, i + 237);
			STEP_2(&context, 2, 6, i + 238);
			STEP_2(&context, 1, 3, i + 239);
			STEP_2(&context, 11, 21, i + 240);
			STEP_2(&context, 1, 12, i + 241);
			STEP_2(&context, 2, 13, i + 242);
			STEP_2(&context, 1, 3, i + 243);
			STEP_2(&context, 4, 14, i + 244);
			STEP_2(&context, 1, 5, i + 245);
			STEP_2(&context, 2, 6, i + 246);
			STEP_2(&context, 1, 3, i + 247);
			STEP_2(&context, 7, 15, i + 248);
			STEP_2(&context, 1, 8, i + 249);
			STEP_2(&context, 2, 9, i + 250);
			STEP_2(&context, 1, 3, i + 251);
			STEP_2(&context, 4, 10, i + 252);
			STEP_2(&context, 1, 5, i + 253);
			STEP_2(&context, 2, 6, i + 254);
			STEP_2(&context, 1, 3, i + 255);
			STEP_2(&context, 37, 9 + alpha, i + 256);
			STEP_2(&context, 1, 38, i + 257);
			STEP_2(&context, 2, 39, i + 258);
			STEP_2(&context, 1, 3, i + 259);
			STEP_2(&context, 4, 40, i + 260);
			STEP_2(&context, 1, 5, i + 261);
			STEP_2(&context, 2, 6, i + 262);
			STEP_2(&context, 1, 3, i + 263);
			STEP_2(&context, 7, 41, i + 264);
			STEP_2(&context, 1, 8, i + 265);
			STEP_2(&context, 2, 9, i + 266);
			STEP_2(&context, 1, 3, i + 267);
			STEP_2(&context, 4, 10, i + 268);
			STEP_2(&context, 1, 5, i + 269);
			STEP_2(&context, 2, 6, i + 270);
			STEP_2(&context, 1, 3, i + 271);
			STEP_2(&context, 11, 42, i + 272);
			STEP_2(&context, 1, 12, i + 273);
			STEP_2(&context, 2, 13, i + 274);
			STEP_2(&context, 1, 3, i + 275);
			STEP_2(&context, 4, 14, i + 276);
			STEP_2(&context, 1, 5, i + 277);
			STEP_2(&context, 2, 6, i + 278);
			STEP_2(&context, 1, 3, i + 279);
			STEP_2(&context, 7, 15, i + 280);
			STEP_2(&context, 1, 8, i + 281);
			STEP_2(&context, 2, 9, i + 282);
			STEP_2(&context, 1, 3, i + 283);
			STEP_2(&context, 4, 10, i + 284);
			STEP_2(&context, 1, 5, i + 285);
			STEP_2(&context, 2, 6, i + 286);
			STEP_2(&context, 1, 3, i + 287);
			STEP_2(&context, 16, 43, i + 288);
			STEP_2(&context, 1, 17, i + 289);
			STEP_2(&context, 2, 18, i + 290);
			STEP_2(&context, 1, 3, i + 291);
			STEP_2(&context, 4, 19, i + 292);
			STEP_2(&context, 1, 5, i + 293);
			STEP_2(&context, 2, 6, i + 294);
			STEP_2(&context, 1, 3, i + 295);
			STEP_2(&context, 7, 20, i + 296);
			STEP_2(&context, 1, 8, i + 297);
			STEP_2(&context, 2, 9, i + 298);
			STEP_2(&context, 1, 3, i + 299);
			STEP_2(&context, 4, 10, i + 300);
			STEP_2(&context, 1, 5, i + 301);
			STEP_2(&context, 2, 6, i + 302);
			STEP_2(&context, 1, 3, i + 303);
			STEP_2(&context, 11, 21, i + 304);
			STEP_2(&context, 1, 12, i + 305);
			STEP_2(&context, 2, 13, i + 306);
			STEP_2(&context, 1, 3, i + 307);
			STEP_2(&context, 4, 14, i + 308);
			STEP_2(&context, 1, 5, i + 309);
			STEP_2(&context, 2, 6, i + 310);
			STEP_2(&context, 1, 3, i + 311);
			STEP_2(&context, 7, 15, i + 312);
			STEP_2(&context, 1, 8, i + 313);
			STEP_2(&context, 2, 9, i + 314);
			STEP_2(&context, 1, 3, i + 315);
			STEP_2(&context, 4, 10, i + 316);
			STEP_2(&context, 1, 5, i + 317);
			STEP_2(&context, 2, 6, i + 318);
			STEP_2(&context, 1, 3, i + 319);
			STEP_2(&context, 22, 44, i + 320);
			STEP_2(&context, 1, 23, i + 321);
			STEP_2(&context, 2, 24, i + 322);
			STEP_2(&context, 1, 3, i + 323);
			STEP_2(&context, 4, 25, i + 324);
			STEP_2(&context, 1, 5, i + 325);
			STEP_2(&context, 2, 6, i + 326);
			STEP_2(&context, 1, 3, i + 327);
			STEP_2(&context, 7, 26, i + 328);
			STEP_2(&context, 1, 8, i + 329);
			STEP_2(&context, 2, 9, i + 330);
			STEP_2(&context, 1, 3, i + 331);
			STEP_2(&context, 4, 10, i + 332);
			STEP_2(&context, 1, 5, i + 333);
			STEP_2(&context, 2, 6, i + 334);
			STEP_2(&context, 1, 3, i + 335);
			STEP_2(&context, 11, 27, i + 336);
			STEP_2(&context, 1, 12, i + 337);
			STEP_2(&context, 2, 13, i + 338);
			STEP_2(&context, 1, 3, i + 339);
			STEP_2(&context, 4, 14, i + 340);
			STEP_2(&context, 1, 5, i + 341);
			STEP_2(&context, 2, 6, i + 342);
			STEP_2(&context, 1, 3, i + 343);
			STEP_2(&context, 7, 15, i + 344);
			STEP_2(&context, 1, 8, i + 345);
			STEP_2(&context, 2, 9, i + 346);
			STEP_2(&context, 1, 3, i + 347);
			STEP_2(&context, 4, 10, i + 348);
			STEP_2(&context, 1, 5, i + 349);
			STEP_2(&context, 2, 6, i + 350);
			STEP_2(&context, 1, 3, i + 351);
			STEP_2(&context, 16, 28, i + 352);
			STEP_2(&context, 1, 17, i + 353);
			STEP_2(&context, 2, 18, i + 354);
			STEP_2(&context, 1, 3, i + 355);
			STEP_2(&context, 4, 19, i + 356);
			STEP_2(&context, 1, 5, i + 357);
			STEP_2(&context, 2, 6, i + 358);
			STEP_2(&context, 1, 3, i + 359);
			STEP_2(&context, 7, 20, i + 360);
			STEP_2(&context, 1, 8, i + 361);
			STEP_2(&context, 2, 9, i + 362);
			STEP_2(&context, 1, 3, i + 363);
			STEP_2(&context, 4, 10, i + 364);
			STEP_2(&context, 1, 5, i + 365);
			STEP_2(&context, 2, 6, i + 366);
			STEP_2(&context, 1, 3, i + 367);
			STEP_2(&context, 11, 21, i + 368);
			STEP_2(&context, 1, 12, i + 369);
			STEP_2(&context, 2, 13, i + 370);
			STEP_2(&context, 1, 3, i + 371);
			STEP_2(&context, 4, 14, i + 372);
			STEP_2(&context, 1, 5, i + 373);
			STEP_2(&context, 2, 6, i + 374);
			STEP_2(&context, 1, 3, i + 375);
			STEP_2(&context, 7, 15, i + 376);
			STEP_2(&context, 1, 8, i + 377);
			STEP_2(&context, 2, 9, i + 378);
			STEP_2(&context, 1, 3, i + 379);
			STEP_2(&context, 4, 10, i + 380);
			STEP_2(&context, 1, 5, i + 381);
			STEP_2(&context, 2, 6, i + 382);
			STEP_2(&context, 1, 3, i + 383);
			STEP_2(&context, 29, 45, i + 384);
			STEP_2(&context, 1, 30, i + 385);
			STEP_2(&context, 2, 31, i + 386);
			STEP_2(&context, 1, 3, i + 387);
			STEP_2(&context, 4, 32, i + 388);
			STEP_2(&context, 1, 5, i + 389);
			STEP_2(&context, 2, 6, i + 390);
			STEP_2(&context, 1, 3, i + 391);
			STEP_2(&context, 7, 33, i + 392);
			STEP_2(&context, 1, 8, i + 393);
			STEP_2(&context, 2, 9, i + 394);
			STEP_2(&context, 1, 3, i + 395);
			STEP_2(&context, 4, 10, i + 396);
			STEP_2(&context, 1, 5, i + 397);
			STEP_2(&context, 2, 6, i + 398);
			STEP_2(&context, 1, 3, i + 399);
			STEP_2(&context, 11, 34, i + 400);
			STEP_2(&context, 1, 12, i + 401);
			STEP_2(&context, 2, 13, i + 402);
			STEP_2(&context, 1, 3, i + 403);
			STEP_2(&context, 4, 14, i + 404);
			STEP_2(&context, 1, 5, i + 405);
			STEP_2(&context, 2, 6, i + 406);
			STEP_2(&context, 1, 3, i + 407);
			STEP_2(&context, 7, 15, i + 408);
			STEP_2(&context, 1, 8, i + 409);
			STEP_2(&context, 2, 9, i + 410);
			STEP_2(&context, 1, 3, i + 411);
			STEP_2(&context, 4, 10, i + 412);
			STEP_2(&context, 1, 5, i + 413);
			STEP_2(&context, 2, 6, i + 414);
			STEP_2(&context, 1, 3, i + 415);
			STEP_2(&context, 16, 35, i + 416);
			STEP_2(&context, 1, 17, i + 417);
			STEP_2(&context, 2, 18, i + 418);
			STEP_2(&context, 1, 3, i + 419);
			STEP_2(&context, 4, 19, i + 420);
			STEP_2(&context, 1, 5, i + 421);
			STEP_2(&context, 2, 6, i + 422);
			STEP_2(&context, 1, 3, i + 423);
			STEP_2(&context, 7, 20, i + 424);
			STEP_2(&context, 1, 8, i + 425);
			STEP_2(&context, 2, 9, i + 426);
			STEP_2(&context, 1, 3, i + 427);
			STEP_2(&context, 4, 10, i + 428);
			STEP_2(&context, 1, 5, i + 429);
			STEP_2(&context, 2, 6, i + 430);
			STEP_2(&context, 1, 3, i + 431);
			STEP_2(&context, 11, 21, i + 432);
			STEP_2(&context, 1, 12, i + 433);
			STEP_2(&context, 2, 13, i + 434);
			STEP_2(&context, 1, 3, i + 435);
			STEP_2(&context, 4, 14, i + 436);
			STEP_2(&context, 1, 5, i + 437);
			STEP_2(&context, 2, 6, i + 438);
			STEP_2(&context, 1, 3, i + 439);
			STEP_2(&context, 7, 15, i + 440);
			STEP_2(&context, 1, 8, i + 441);
			STEP_2(&context, 2, 9, i + 442);
			STEP_2(&context, 1, 3, i + 443);
			STEP_2(&context, 4, 10, i + 444);
			STEP_2(&context, 1, 5, i + 445);
			STEP_2(&context, 2, 6, i + 446);
			STEP_2(&context, 1, 3, i + 447);
			STEP_2(&context, 22, 36, i + 448);
			STEP_2(&context, 1, 23, i + 449);
			STEP_2(&context, 2, 24, i + 450);
			STEP_2(&context, 1, 3, i + 451);
			STEP_2(&context, 4, 25, i + 452);
			STEP_2(&context, 1, 5, i + 453);
			STEP_2(&context, 2, 6, i + 454);
			STEP_2(&context, 1, 3, i + 455);
			STEP_2(&context, 7, 26, i + 456);
			STEP_2(&context, 1, 8, i + 457);
			STEP_2(&context, 2, 9, i + 458);
			STEP_2(&context, 1, 3, i + 459);
			STEP_2(&context, 4, 10, i + 460);
			STEP_2(&context, 1, 5, i + 461);
			STEP_2(&context, 2, 6, i + 462);
			STEP_2(&context, 1, 3, i + 463);
			STEP_2(&context, 11, 27, i + 464);
			STEP_2(&context, 1, 12, i + 465);
			STEP_2(&context, 2, 13, i + 466);
			STEP_2(&context, 1, 3, i + 467);
			STEP_2(&context, 4, 14, i + 468);
			STEP_2(&context, 1, 5, i + 469);
			STEP_2(&context, 2, 6, i + 470);
			STEP_2(&context, 1, 3, i + 471);
			STEP_2(&context, 7, 15, i + 472);
			STEP_2(&context, 1, 8, i + 473);
			STEP_2(&context, 2, 9, i + 474);
			STEP_2(&context, 1, 3, i + 475);
			STEP_2(&context, 4, 10, i + 476);
			STEP_2(&context, 1, 5, i + 477);
			STEP_2(&context, 2, 6, i + 478);
			STEP_2(&context, 1, 3, i + 479);
			STEP_2(&context, 16, 28, i + 480);
			STEP_2(&context, 1, 17, i + 481);
			STEP_2(&context, 2, 18, i + 482);
			STEP_2(&context, 1, 3, i + 483);
			STEP_2(&context, 4, 19, i + 484);
			STEP_2(&context, 1, 5, i + 485);
			STEP_2(&context, 2, 6, i + 486);
			STEP_2(&context, 1, 3, i + 487);
			STEP_2(&context, 7, 20, i + 488);
			STEP_2(&context, 1, 8, i + 489);
			STEP_2(&context, 2, 9, i + 490);
			STEP_2(&context, 1, 3, i + 491);
			STEP_2(&context, 4, 10, i + 492);
			STEP_2(&context, 1, 5, i + 493);
			STEP_2(&context, 2, 6, i + 494);
			STEP_2(&context, 1, 3, i + 495);
			STEP_2(&context, 11, 21, i + 496);
			STEP_2(&context, 1, 12, i + 497);
			STEP_2(&context, 2, 13, i + 498);
			STEP_2(&context, 1, 3, i + 499);
			STEP_2(&context, 4, 14, i + 500);
			STEP_2(&context, 1, 5, i + 501);
			STEP_2(&context, 2, 6, i + 502);
			STEP_2(&context, 1, 3, i + 503);
			STEP_2(&context, 7, 15, i + 504);
			STEP_2(&context, 1, 8, i + 505);
			STEP_2(&context, 2, 9, i + 506);
			STEP_2(&context, 1, 3, i + 507);
			STEP_2(&context, 4, 10, i + 508);
			STEP_2(&context, 1, 5, i + 509);
			STEP_2(&context, 2, 6, i + 510);
			STEP_2(&context, 1, 3, i + 511);

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
