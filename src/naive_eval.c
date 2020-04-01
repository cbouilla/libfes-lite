#include "fes.h"

u32 feslite_naive_evaluation(int n, const u32 * Fq, const u32 * Fl, int stride, u32 x)
{
	// first expand the values of the variables from `x`
	u32 v[32];
	for (int k = 0; k < n; k++) {
		v[k] = (x & 0x0001) ? 0xffffffff : 0x00000000;
		x >>= 1;
	}

	u32 y = Fl[0];

	for (int idx_0 = 0; idx_0 < n; idx_0++) {
		// computes the contribution of degree-1 terms
		u32 v_0 = v[idx_0];
		u32 l = Fl[stride * (1 + idx_0)];   // FIXME : get rid of this multiplication
		y ^= l & v_0;

		for (int idx_1 = 0; idx_1 < idx_0; idx_1++) {
			// computes the contribution of degree-2 terms
			u32 v_1 = v_0 & v[idx_1];
			u32 q = Fq[idxq(idx_1, idx_0)];
			y ^= q & v_1;
		}
	}
	return y;
}
