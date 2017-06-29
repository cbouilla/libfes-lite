#include <assert.h>

#include "feslite.h"
#include "monomials.h"


/* this code was written by Antoine Joux for his book 
  "algorithmic cryptanalysis" (cf. http://www.joux.biz). It
  was slighlty modified by C. Bouillaguet. Just like the original, it is licensed 
  under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License. */

static const uint64_t M1_HI = 0xffffffff00000000;
static const uint64_t M1_LO = 0x00000000ffffffff;

static const uint64_t M2_HI = 0xffff0000ffff0000;
static const uint64_t M2_LO = 0x0000ffff0000ffff;

static const uint64_t M3_HI = 0xff00ff00ff00ff00;
static const uint64_t M3_LO = 0x00ff00ff00ff00ff;

static const uint64_t M4_HI = 0xf0f0f0f0f0f0f0f0;
static const uint64_t M4_LO = 0x0f0f0f0f0f0f0f0f;

static const uint64_t M5_HI = 0xcccccccccccccccc;
static const uint64_t M5_LO = 0x3333333333333333;

static const uint64_t M6_HI = 0xaaaaaaaaaaaaaaaa;
static const uint64_t M6_LO = 0x5555555555555555;


static void transpose_64(uint64_t * T, uint64_t * M)
{
	/* to unroll manually */
	for (int l = 0; l < 32; l++) {
		T[l] = (M[l] & M1_LO) | ((M[l + 32] & M1_LO) << 32);
		T[l + 32] = ((M[l] & M1_HI) >> 32) | (M[l + 32] & M1_HI);
	}

	for (int l0 = 0; l0 < 64; l0 += 32) {
		for (int l = l0; l < l0 + 16; l++) {
			uint64_t val1 = (T[l] & M2_LO) | ((T[l + 16] & M2_LO) << 16);
			uint64_t val2 = ((T[l] & M2_HI) >> 16) | (T[l + 16] & M2_HI);
			T[l] = val1;
			T[l + 16] = val2;
		}
	}

	for (int l0 = 0; l0 < 64; l0 += 16) {
		for (int l = l0; l < l0 + 8; l++) {
			uint64_t val1 = (T[l] & M3_LO) | ((T[l + 8] & M3_LO) << 8);
			uint64_t val2 = ((T[l] & M3_HI) >> 8) | (T[l + 8] & M3_HI);
			T[l] = val1;
			T[l + 8] = val2;
		}
	}

	for (int l0 = 0; l0 < 64; l0 += 8) {
		for (int l = l0; l < l0 + 4; l++) {
			uint64_t val1 = (T[l] & M4_LO) | ((T[l + 4] & M4_LO) << 4);
			uint64_t val2 = ((T[l] & M4_HI) >> 4) | (T[l + 4] & M4_HI);
			T[l] = val1;
			T[l + 4] = val2;
		}
	}

	for (int l0 = 0; l0 < 64; l0 += 4) {
		for (int l = l0; l < l0 + 2; l++) {
			uint64_t val1 = (T[l] & M5_LO) | ((T[l + 2] & M5_LO) << 2);
			uint64_t val2 = ((T[l] & M5_HI) >> 2) | (T[l + 2] & M5_HI);
			T[l] = val1;
			T[l + 2] = val2;
		}
	}

	for (int l = 0; l < 64; l += 2) {
		uint64_t val1 = (T[l] & M6_LO) | ((T[l + 1] & M6_LO) << 1);
		uint64_t val2 = ((T[l] & M6_HI) >> 1) | (T[l + 1] & M6_HI);
		T[l] = val1;
		T[l + 1] = val2;
	}
}


/* the input is 64x32 */

size_t generic_eval_64(int n, const uint32_t * const F,
			    __attribute__((unused)) size_t eq_from, __attribute__((unused)) size_t eq_to,
			    uint32_t *input, size_t n_input,
			    uint32_t *solutions, size_t max_solutions,
			    __attribute__((unused)) int verbose)
{
	assert(n_input <= 64);
	assert(max_solutions > 0);
	size_t n_solution = 0;
	
	uint64_t bitslice[64];
	transpose_64(bitslice, input);

	uint32_t valid = 0xffffffff;
	for (size_t i = eq_from; i < eq_to; i++) {
		uint32_t y = (F[0] & (1 << i)) ? 0xffffffff : 0;	
	
		for (size_t j = 0; j < n; j++)
			y ^= bitslice[j] & ((F[idx_1(j)] & (1 << i)) ? 0xffffffff : 0);

		for (size_t j = 0; j < n; j++)
			for (size_t k = 0; k < j; k++)
				y ^= bitslice[j] & bitslice[k] & ((F[idx_2(k, j)] & (1 << i)) ? 0xffffffff : 0);
	
		valid &= ~y;
		if (!valid)
			return 0;
	}

	for (size_t i = 0; i < n_input; i++)
		if (valid & (1 << i)) {
			solutions[n_solution++] = input[i];
			if (n_solution == max_solutions)
				break;
		}

	return n_solution;
}