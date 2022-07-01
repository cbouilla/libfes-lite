#include <stdio.h>
#include <assert.h>

/* 
 * check that we are capable of recomputing the full enumeration state from 
 * scratch at any point. 
 */		


#include "rand.h"
#include "fes.h"

#define L 5

static inline void UNROLLED_CHUNK(const u32 *Fq, u32 * Fl, int alpha, int beta, int gamma)
{
	Fl[0] ^= (Fl[1] ^= Fq[alpha + 0]);
	Fl[0] ^= (Fl[2] ^= Fq[alpha + 1]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[alpha + 2]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[alpha + 3]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[alpha + 4]);
	Fl[0] ^= (Fl[1] ^= Fq[6]);
	Fl[0] ^= (Fl[2] ^= Fq[7]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[8]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[9]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[beta] ^= Fq[gamma]);
}

void simple_kernel_simulation(int n, const u32 * original_Fq, const u32 * original_Fl)
{
	u32 Fq[561];
	u32 Fl[34];

	setup32(n, 1, original_Fq, original_Fl, Fq, Fl);

	struct ffs_t ffs;
	ffs_reset(&ffs, n-L);
	int k1 = ffs.k1 + L;
	int k2 = ffs.k2 + L;

	u32 iterations = 1ul << (n - L);
	for (u32 j = 0; j < iterations; j++) {
		u32 i = j << L;

		/* first, the constant term */
		assert(Fl[0] == feslite_naive_evaluation(n, original_Fq, original_Fl, 1, to_gray(i)));
		
		/* next, the n linear terms */
		for (int k = 0; k < n; k++) {
			u32 y = original_Fl[1+k];
			if (i >= (1 << k)) { /* term has been modified by the enumeration */
				if (k > 0)
					y ^= original_Fq[idxq(k-1, k)];
				u32 x = to_gray(i - (1 << k)) >> (k + 1);
				for (int j = 0; j < n; j++)
					if (x & (1 << j))
						y ^= original_Fq[idxq(k, k + 1 + j)];
			}
			assert(Fl[1 + k] == y);
		}

		int alpha = idxq(0, k1);
		ffs_step(&ffs);	
		k1 = ffs.k1 + L;
		k2 = ffs.k2 + L;
		int beta = 1 + k1;
		int gamma = idxq(k1, k2);
		UNROLLED_CHUNK(Fq, Fl, alpha, beta, gamma);
	}
}


int main()
{	
	int n = 24;
	mysrand(42);
	u32 Fl[33];
	u32 Fq[496];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33 ; i++)
		Fl[i] = myrand();
		
	simple_kernel_simulation(n, Fq, Fl);
	printf("1..1\n");
	printf("ok 1 - I did not crash!\n");

	return 0;
}