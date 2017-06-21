#include <assert.h>
#include "feslite.h"


/* this code was written by Antoine Joux for his book 
  "algorithmic cryptanalysis" (cf. http://www.joux.biz). It
  was slighlty modified by C. Bouillaguet. Just like the original, it is licensed 
  under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License. */
void transpose(uint32_t * T, uint32_t * M)
{
	/* to unroll manually */
	for (int l = 0; l < 16; l++) {
		T[l] = (M[l] & 0xffff) | ((M[l + 16] & 0xffff) << 16);
		T[l + 16] = ((M[l] & 0xffff0000) >> 16) | (M[l + 16] & 0xffff0000);
	}

	for (int l0 = 0; l0 < 32; l0 += 16) {
		for (int l = l0; l < l0 + 8; l++) {
			uint32_t val1 = (T[l] & 0xff00ff) | ((T[l + 8] & 0xff00ff) << 8);
			uint32_t val2 = ((T[l] & 0xff00ff00) >> 8) | (T[l + 8] & 0xff00ff00);
			T[l] = val1;
			T[l + 8] = val2;
		}
	}

	for (int l0 = 0; l0 < 32; l0 += 8) {
		for (int l = l0; l < l0 + 4; l++) {
			uint32_t val1 = (T[l] & 0xf0f0f0f) | ((T[l + 4] & 0xf0f0f0f) << 4);
			uint32_t val2 = ((T[l] & 0xf0f0f0f0) >> 4) | (T[l + 4] & 0xf0f0f0f0);
			T[l] = val1;
			T[l + 4] = val2;
		}
	}

	for (int l0 = 0; l0 < 32; l0 += 4) {
		for (int l = l0; l < l0 + 2; l++) {
			uint32_t val1 = (T[l] & 0x33333333) | ((T[l + 2] & 0x33333333) << 2);
			uint32_t val2 = ((T[l] & 0xcccccccc) >> 2) | (T[l + 2] & 0xcccccccc);
			T[l] = val1;
			T[l + 2] = val2;
		}
	}

	for (int l = 0; l < 32; l += 2) {
		uint32_t val1 = (T[l] & 0x55555555) | ((T[l + 1] & 0x55555555) << 1);
		uint32_t val2 = ((T[l] & 0xaaaaaaaa) >> 1) | (T[l + 1] & 0xaaaaaaaa);
		T[l] = val1;
		T[l + 1] = val2;
	}
}


size_t generic_eval_32(int n, const uint32_t * const F,
			    __attribute__((unused)) size_t eq_from, __attribute__((unused)) size_t eq_to,
			    uint32_t *input, size_t n_input,
			    uint32_t *solutions, size_t max_solutions,
			    __attribute__((unused)) int verbose)
{
	/*uint32_t bitslice[32];
	transpose_32(bitslice, input);

	uint32_t valid = 0xffffffff;
	for (size_t i = eq_from; i < eq_to; i++) {
		uint32_t y = F[0];	
	}*/

	assert(n_input <= 32);
	size_t n_solution = 0;
	if (n_solution == max_solutions)
		return n_solution;

	for (size_t i = 0; i < n_input; i++) {
		if (naive_evaluation(n, F, input[i]) == 0) {
			solutions[n_solution++] = input[i];
			if (n_solution == max_solutions)
				return n_solution;
		}
	}
	return n_solution;
	
}