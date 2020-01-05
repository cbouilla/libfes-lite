#include "feslite.h"
#include "monomials.h"

uint32_t feslite_naive_evaluation(int n, const uint32_t * const F, uint32_t x)
{
	// first expand the values of the variables from `x`
	uint32_t v[n];
	for (int k = 0; k < n; k++) {
		v[k] = (x & 0x0001) ? 0xffffffff : 0x00000000;
		x >>= 1;
	}

	uint32_t y = F[0];

	for (int idx_0 = 0; idx_0 < n; idx_0++) {
		// computes the contribution of degree-1 terms
		const uint32_t v_0 = v[idx_0];
		y ^= F[idx_1(idx_0)] & v_0;

		for (int idx_1 = 0; idx_1 < idx_0; idx_1++) {
			// computes the contribution of degree-2 terms
			const uint32_t v_1 = v_0 & v[idx_1];
			y ^= F[idx_2(idx_1, idx_0)] & v_1;
		}
	}
	return y;
}
