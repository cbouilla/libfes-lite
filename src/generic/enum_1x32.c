#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <getopt.h>

#include "monomials.h"

#define L 8

struct solution_t {
  uint32_t x;
};

struct context_t {
	int n;
	const uint32_t * const F_start;
	uint32_t * F;
	struct solution_t buffer[(1 << L) + 32];
	size_t buffer_size;
	uint32_t *solutions;
	size_t max_solutions;
	size_t n_solutions;

	size_t focus[33];
	size_t stack[32];
	size_t sp;

	int verbose;
};



static inline void CHECK_SOLUTION(struct context_t *context, uint32_t index)
{
	if (unlikely((context->F[0] == 0))) {
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

static inline void FLUSH_BUFFER(struct context_t *context)
{		
	for (size_t i = 0; i < context->buffer_size; i++) {
		uint32_t x = to_gray(context->buffer[i].x);
		context->solutions[context->n_solutions++] = x;
		if (context->n_solutions == context->max_solutions)
			return;
	}
	context->buffer_size = 0;
}				

static inline int b_1(struct context_t *context)
{
	size_t j = context->focus[0];
	context->focus[0] = 0;
	context->focus[j] = context->focus[j + 1];
	context->focus[j + 1] = j + 1;
    	return j;
}

static inline int b_2(struct context_t *context, size_t j)
{
	context->sp -= j;
	int x = context->stack[context->sp - 1];
	context->stack[context->sp++] = j;
	return x;
}


static inline void unrolled_chunk(struct context_t *context, int alpha, uint32_t i)
{
	STEP_2(context, 1, 1 + alpha, i + 1);
	STEP_2(context, 2, 2 + alpha, i + 2);
	STEP_2(context, 1, 3, i + 3);
	STEP_2(context, 4, 3 + alpha, i + 4);
	STEP_2(context, 1, 5, i + 5);
	STEP_2(context, 2, 6, i + 6);
	STEP_2(context, 1, 3, i + 7);
	STEP_2(context, 7, 4 + alpha, i + 8);
	STEP_2(context, 1, 8, i + 9);
	STEP_2(context, 2, 9, i + 10);
	STEP_2(context, 1, 3, i + 11);
	STEP_2(context, 4, 10, i + 12);
	STEP_2(context, 1, 5, i + 13);
	STEP_2(context, 2, 6, i + 14);
	STEP_2(context, 1, 3, i + 15);
	STEP_2(context, 11, 5 + alpha, i + 16);
	STEP_2(context, 1, 12, i + 17);
	STEP_2(context, 2, 13, i + 18);
	STEP_2(context, 1, 3, i + 19);
	STEP_2(context, 4, 14, i + 20);
	STEP_2(context, 1, 5, i + 21);
	STEP_2(context, 2, 6, i + 22);
	STEP_2(context, 1, 3, i + 23);
	STEP_2(context, 7, 15, i + 24);
	STEP_2(context, 1, 8, i + 25);
	STEP_2(context, 2, 9, i + 26);
	STEP_2(context, 1, 3, i + 27);
	STEP_2(context, 4, 10, i + 28);
	STEP_2(context, 1, 5, i + 29);
	STEP_2(context, 2, 6, i + 30);
	STEP_2(context, 1, 3, i + 31);
	STEP_2(context, 16, 6 + alpha, i + 32);
	STEP_2(context, 1, 17, i + 33);
	STEP_2(context, 2, 18, i + 34);
	STEP_2(context, 1, 3, i + 35);
	STEP_2(context, 4, 19, i + 36);
	STEP_2(context, 1, 5, i + 37);
	STEP_2(context, 2, 6, i + 38);
	STEP_2(context, 1, 3, i + 39);
	STEP_2(context, 7, 20, i + 40);
	STEP_2(context, 1, 8, i + 41);
	STEP_2(context, 2, 9, i + 42);
	STEP_2(context, 1, 3, i + 43);
	STEP_2(context, 4, 10, i + 44);
	STEP_2(context, 1, 5, i + 45);
	STEP_2(context, 2, 6, i + 46);
	STEP_2(context, 1, 3, i + 47);
	STEP_2(context, 11, 21, i + 48);
	STEP_2(context, 1, 12, i + 49);
	STEP_2(context, 2, 13, i + 50);
	STEP_2(context, 1, 3, i + 51);
	STEP_2(context, 4, 14, i + 52);
	STEP_2(context, 1, 5, i + 53);
	STEP_2(context, 2, 6, i + 54);
	STEP_2(context, 1, 3, i + 55);
	STEP_2(context, 7, 15, i + 56);
	STEP_2(context, 1, 8, i + 57);
	STEP_2(context, 2, 9, i + 58);
	STEP_2(context, 1, 3, i + 59);
	STEP_2(context, 4, 10, i + 60);
	STEP_2(context, 1, 5, i + 61);
	STEP_2(context, 2, 6, i + 62);
	STEP_2(context, 1, 3, i + 63);
	STEP_2(context, 22, 7 + alpha, i + 64);
	STEP_2(context, 1, 23, i + 65);
	STEP_2(context, 2, 24, i + 66);
	STEP_2(context, 1, 3, i + 67);
	STEP_2(context, 4, 25, i + 68);
	STEP_2(context, 1, 5, i + 69);
	STEP_2(context, 2, 6, i + 70);
	STEP_2(context, 1, 3, i + 71);
	STEP_2(context, 7, 26, i + 72);
	STEP_2(context, 1, 8, i + 73);
	STEP_2(context, 2, 9, i + 74);
	STEP_2(context, 1, 3, i + 75);
	STEP_2(context, 4, 10, i + 76);
	STEP_2(context, 1, 5, i + 77);
	STEP_2(context, 2, 6, i + 78);
	STEP_2(context, 1, 3, i + 79);
	STEP_2(context, 11, 27, i + 80);
	STEP_2(context, 1, 12, i + 81);
	STEP_2(context, 2, 13, i + 82);
	STEP_2(context, 1, 3, i + 83);
	STEP_2(context, 4, 14, i + 84);
	STEP_2(context, 1, 5, i + 85);
	STEP_2(context, 2, 6, i + 86);
	STEP_2(context, 1, 3, i + 87);
	STEP_2(context, 7, 15, i + 88);
	STEP_2(context, 1, 8, i + 89);
	STEP_2(context, 2, 9, i + 90);
	STEP_2(context, 1, 3, i + 91);
	STEP_2(context, 4, 10, i + 92);
	STEP_2(context, 1, 5, i + 93);
	STEP_2(context, 2, 6, i + 94);
	STEP_2(context, 1, 3, i + 95);
	STEP_2(context, 16, 28, i + 96);
	STEP_2(context, 1, 17, i + 97);
	STEP_2(context, 2, 18, i + 98);
	STEP_2(context, 1, 3, i + 99);
	STEP_2(context, 4, 19, i + 100);
	STEP_2(context, 1, 5, i + 101);
	STEP_2(context, 2, 6, i + 102);
	STEP_2(context, 1, 3, i + 103);
	STEP_2(context, 7, 20, i + 104);
	STEP_2(context, 1, 8, i + 105);
	STEP_2(context, 2, 9, i + 106);
	STEP_2(context, 1, 3, i + 107);
	STEP_2(context, 4, 10, i + 108);
	STEP_2(context, 1, 5, i + 109);
	STEP_2(context, 2, 6, i + 110);
	STEP_2(context, 1, 3, i + 111);
	STEP_2(context, 11, 21, i + 112);
	STEP_2(context, 1, 12, i + 113);
	STEP_2(context, 2, 13, i + 114);
	STEP_2(context, 1, 3, i + 115);
	STEP_2(context, 4, 14, i + 116);
	STEP_2(context, 1, 5, i + 117);
	STEP_2(context, 2, 6, i + 118);
	STEP_2(context, 1, 3, i + 119);
	STEP_2(context, 7, 15, i + 120);
	STEP_2(context, 1, 8, i + 121);
	STEP_2(context, 2, 9, i + 122);
	STEP_2(context, 1, 3, i + 123);
	STEP_2(context, 4, 10, i + 124);
	STEP_2(context, 1, 5, i + 125);
	STEP_2(context, 2, 6, i + 126);
	STEP_2(context, 1, 3, i + 127);
	STEP_2(context, 29, 8 + alpha, i + 128);
	STEP_2(context, 1, 30, i + 129);
	STEP_2(context, 2, 31, i + 130);
	STEP_2(context, 1, 3, i + 131);
	STEP_2(context, 4, 32, i + 132);
	STEP_2(context, 1, 5, i + 133);
	STEP_2(context, 2, 6, i + 134);
	STEP_2(context, 1, 3, i + 135);
	STEP_2(context, 7, 33, i + 136);
	STEP_2(context, 1, 8, i + 137);
	STEP_2(context, 2, 9, i + 138);
	STEP_2(context, 1, 3, i + 139);
	STEP_2(context, 4, 10, i + 140);
	STEP_2(context, 1, 5, i + 141);
	STEP_2(context, 2, 6, i + 142);
	STEP_2(context, 1, 3, i + 143);
	STEP_2(context, 11, 34, i + 144);
	STEP_2(context, 1, 12, i + 145);
	STEP_2(context, 2, 13, i + 146);
	STEP_2(context, 1, 3, i + 147);
	STEP_2(context, 4, 14, i + 148);
	STEP_2(context, 1, 5, i + 149);
	STEP_2(context, 2, 6, i + 150);
	STEP_2(context, 1, 3, i + 151);
	STEP_2(context, 7, 15, i + 152);
	STEP_2(context, 1, 8, i + 153);
	STEP_2(context, 2, 9, i + 154);
	STEP_2(context, 1, 3, i + 155);
	STEP_2(context, 4, 10, i + 156);
	STEP_2(context, 1, 5, i + 157);
	STEP_2(context, 2, 6, i + 158);
	STEP_2(context, 1, 3, i + 159);
	STEP_2(context, 16, 35, i + 160);
	STEP_2(context, 1, 17, i + 161);
	STEP_2(context, 2, 18, i + 162);
	STEP_2(context, 1, 3, i + 163);
	STEP_2(context, 4, 19, i + 164);
	STEP_2(context, 1, 5, i + 165);
	STEP_2(context, 2, 6, i + 166);
	STEP_2(context, 1, 3, i + 167);
	STEP_2(context, 7, 20, i + 168);
	STEP_2(context, 1, 8, i + 169);
	STEP_2(context, 2, 9, i + 170);
	STEP_2(context, 1, 3, i + 171);
	STEP_2(context, 4, 10, i + 172);
	STEP_2(context, 1, 5, i + 173);
	STEP_2(context, 2, 6, i + 174);
	STEP_2(context, 1, 3, i + 175);
	STEP_2(context, 11, 21, i + 176);
	STEP_2(context, 1, 12, i + 177);
	STEP_2(context, 2, 13, i + 178);
	STEP_2(context, 1, 3, i + 179);
	STEP_2(context, 4, 14, i + 180);
	STEP_2(context, 1, 5, i + 181);
	STEP_2(context, 2, 6, i + 182);
	STEP_2(context, 1, 3, i + 183);
	STEP_2(context, 7, 15, i + 184);
	STEP_2(context, 1, 8, i + 185);
	STEP_2(context, 2, 9, i + 186);
	STEP_2(context, 1, 3, i + 187);
	STEP_2(context, 4, 10, i + 188);
	STEP_2(context, 1, 5, i + 189);
	STEP_2(context, 2, 6, i + 190);
	STEP_2(context, 1, 3, i + 191);
	STEP_2(context, 22, 36, i + 192);
	STEP_2(context, 1, 23, i + 193);
	STEP_2(context, 2, 24, i + 194);
	STEP_2(context, 1, 3, i + 195);
	STEP_2(context, 4, 25, i + 196);
	STEP_2(context, 1, 5, i + 197);
	STEP_2(context, 2, 6, i + 198);
	STEP_2(context, 1, 3, i + 199);
	STEP_2(context, 7, 26, i + 200);
	STEP_2(context, 1, 8, i + 201);
	STEP_2(context, 2, 9, i + 202);
	STEP_2(context, 1, 3, i + 203);
	STEP_2(context, 4, 10, i + 204);
	STEP_2(context, 1, 5, i + 205);
	STEP_2(context, 2, 6, i + 206);
	STEP_2(context, 1, 3, i + 207);
	STEP_2(context, 11, 27, i + 208);
	STEP_2(context, 1, 12, i + 209);
	STEP_2(context, 2, 13, i + 210);
	STEP_2(context, 1, 3, i + 211);
	STEP_2(context, 4, 14, i + 212);
	STEP_2(context, 1, 5, i + 213);
	STEP_2(context, 2, 6, i + 214);
	STEP_2(context, 1, 3, i + 215);
	STEP_2(context, 7, 15, i + 216);
	STEP_2(context, 1, 8, i + 217);
	STEP_2(context, 2, 9, i + 218);
	STEP_2(context, 1, 3, i + 219);
	STEP_2(context, 4, 10, i + 220);
	STEP_2(context, 1, 5, i + 221);
	STEP_2(context, 2, 6, i + 222);
	STEP_2(context, 1, 3, i + 223);
	STEP_2(context, 16, 28, i + 224);
	STEP_2(context, 1, 17, i + 225);
	STEP_2(context, 2, 18, i + 226);
	STEP_2(context, 1, 3, i + 227);
	STEP_2(context, 4, 19, i + 228);
	STEP_2(context, 1, 5, i + 229);
	STEP_2(context, 2, 6, i + 230);
	STEP_2(context, 1, 3, i + 231);
	STEP_2(context, 7, 20, i + 232);
	STEP_2(context, 1, 8, i + 233);
	STEP_2(context, 2, 9, i + 234);
	STEP_2(context, 1, 3, i + 235);
	STEP_2(context, 4, 10, i + 236);
	STEP_2(context, 1, 5, i + 237);
	STEP_2(context, 2, 6, i + 238);
	STEP_2(context, 1, 3, i + 239);
	STEP_2(context, 11, 21, i + 240);
	STEP_2(context, 1, 12, i + 241);
	STEP_2(context, 2, 13, i + 242);
	STEP_2(context, 1, 3, i + 243);
	STEP_2(context, 4, 14, i + 244);
	STEP_2(context, 1, 5, i + 245);
	STEP_2(context, 2, 6, i + 246);
	STEP_2(context, 1, 3, i + 247);
	STEP_2(context, 7, 15, i + 248);
	STEP_2(context, 1, 8, i + 249);
	STEP_2(context, 2, 9, i + 250);
	STEP_2(context, 1, 3, i + 251);
	STEP_2(context, 4, 10, i + 252);
	STEP_2(context, 1, 5, i + 253);
	STEP_2(context, 2, 6, i + 254);
	STEP_2(context, 1, 3, i + 255);
}

// generated with L = 9
size_t generic_enum_1x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose)
{
	uint64_t init_start_time = Now();

	struct context_t context;
	context.n = n;
	context.solutions = solutions;
	context.n_solutions = 0;
	context.max_solutions = max_solutions;
	context.verbose = verbose;
	context.buffer_size = 0;

	context.sp = 1;
	context.stack[0] = -1;
	for (int j = 0; j <= n; j++)
		context.focus[j] = j;

	size_t N = idx_1(n);
	uint32_t F[N];
	for (size_t i = 0; i < N; i++)
		F[i] = F_[i];
	context.F = F;

	/* compute "derivatives" */
	/* degree-1 terms are affected by degree-2 terms */
	for (int i = 1; i < n; i++)
		F[idx_1(i)] ^= F[idx_2(i - 1, i)];

	if (verbose)
		printf("fes: initialisation = %" PRIu64 " cycles\n",
		       Now() - init_start_time);
	uint64_t enumeration_start_time = Now();
	size_t n_solutions = 0;

	// special case for i=0
	STEP_0(&context, 0);

	// from now on, hamming weight is >= 1
	for (int idx_0 = 0; idx_0 < min(n, L); idx_0++) {

		// special case when i has hamming weight exactly 1
		uint32_t w1 = (1 << idx_0);
		STEP_1(&context, idx_1(idx_0), w1);

		// we are now inside the critical part where the hamming weight is known to be >= 2
		// Thus, there are no special cases from now on

		// Because of the last step, the current iteration counter is a multiple of 512 plus one
		// This loop sets it to `rolled_end`, which is a multiple of 512, if possible

		for (uint32_t i = 1 + w1; i < 2 * w1; i++) {
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
			//printf("%08x (rolled)\n", i);
			STEP_2(&context, idx_1(k_1), idx_2(k_1, k_2), i);
		}

		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;
	}

	// Here, the number of iterations to perform is (supposedly) sufficiently large
	// We will therefore unroll the loop 512 times

	for (int idx_0 = L; idx_0 < n; idx_0++) {	

		// special case when i has hamming weight exactly 1
		uint32_t w1 = (1 << idx_0);
		STEP_1(&context, idx_1(idx_0), w1);
		
		unrolled_chunk(&context, idx_1(idx_0), w1);
			
		FLUSH_BUFFER(&context);
		if (context.n_solutions == context.max_solutions)
			return context.n_solutions;

		// unrolled critical section where the hamming weight is >= 2
		for (uint32_t j = (1 << L); j < (1ull << idx_0); j += (1 << L)) {
			const uint32_t i = j + w1;
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
			//printf("%08x (unrolled start)\n", i);

			STEP_2(&context, alpha, beta, i);
			unrolled_chunk(&context, alpha, i);
			
			FLUSH_BUFFER(&context);
			if (context.n_solutions == context.max_solutions)
				return context.n_solutions;
		}

	}

	uint64_t end_time = Now();
	if (verbose)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n",
		       end_time - enumeration_start_time);

	for (size_t i = 0; i < n_solutions; i++)
		solutions[i] = to_gray(solutions[i]);

	return context.n_solutions;
}
