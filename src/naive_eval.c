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

	for (int i = 0; i < n; i++) {
		// computes the contribution of degree-1 terms
		u32 v_0 = v[i];
		u32 l = Fl[stride * (1 + i)];   // FIXME : get rid of this multiplication
		y ^= l & v_0;

		for (int j = 0; j < i; j++) {
			// computes the contribution of degree-2 terms
			u32 v_1 = v_0 & v[j];
			u32 q = Fq[idxq(j, i)];
			y ^= q & v_1;
		}
	}
	return y;
}
