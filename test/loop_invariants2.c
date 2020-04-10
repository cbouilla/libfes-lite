#include <stdio.h>
#include <assert.h>

/* 
 * check that we are capable of undoing/redoing the effect of a bunch of steps
 * at once. 
 */		


#include "rand.h"
#include "fes.h"

#define L 8


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
	Fl[0] ^= (Fl[6] ^= Fq[alpha + 5]);
	Fl[0] ^= (Fl[1] ^= Fq[10]);
	Fl[0] ^= (Fl[2] ^= Fq[11]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[12]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[13]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[14]);
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
	Fl[0] ^= (Fl[7] ^= Fq[alpha + 6]);
	Fl[0] ^= (Fl[1] ^= Fq[15]);
	Fl[0] ^= (Fl[2] ^= Fq[16]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[17]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[18]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[19]);
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
	Fl[0] ^= (Fl[6] ^= Fq[20]);
	Fl[0] ^= (Fl[1] ^= Fq[10]);
	Fl[0] ^= (Fl[2] ^= Fq[11]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[12]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[13]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[14]);
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
	Fl[0] ^= (Fl[8] ^= Fq[alpha + 7]);
	Fl[0] ^= (Fl[1] ^= Fq[21]);
	Fl[0] ^= (Fl[2] ^= Fq[22]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[23]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[24]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[25]);
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
	Fl[0] ^= (Fl[6] ^= Fq[26]);
	Fl[0] ^= (Fl[1] ^= Fq[10]);
	Fl[0] ^= (Fl[2] ^= Fq[11]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[12]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[13]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[14]);
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
	Fl[0] ^= (Fl[7] ^= Fq[27]);
	Fl[0] ^= (Fl[1] ^= Fq[15]);
	Fl[0] ^= (Fl[2] ^= Fq[16]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[17]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[18]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[19]);
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
	Fl[0] ^= (Fl[6] ^= Fq[20]);
	Fl[0] ^= (Fl[1] ^= Fq[10]);
	Fl[0] ^= (Fl[2] ^= Fq[11]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[12]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[4] ^= Fq[13]);
	Fl[0] ^= (Fl[1] ^= Fq[3]);
	Fl[0] ^= (Fl[2] ^= Fq[4]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[3] ^= Fq[5]);
	Fl[0] ^= (Fl[1] ^= Fq[1]);
	Fl[0] ^= (Fl[2] ^= Fq[2]);
	Fl[0] ^= (Fl[1] ^= Fq[0]);
	Fl[0] ^= (Fl[5] ^= Fq[14]);
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


static u32 gemv(int n, const u32 * M, u32 x)
{
	u32 r = M[0];
	for (int i = 0; i < n; i++)
		if (x & (1 << i))
			r ^= M[i + 1];
	return r;
}

static inline void FAST_FORWARD(int n, const u32 *Fq, u32 *Fl, const u32 * original_Fl, const u32 (*D)[33],
	int alpha, int beta, int gamma, u32 i)
{
	u32 mv = gemv(n+1, D[beta-1], to_gray(i));
	Fl[0] ^= original_Fl[L] ^ original_Fl[beta] ^ mv;
		
	/* update the derivatives */
	for (int i = 0; i < L; i++)
		Fl[1 + i] ^= Fq[alpha + i];
	for (int i = 0; i < L - 1; i++)
		Fl[1 + i] ^= Fq[idxq(0, L-1) + i];
	Fl[beta] ^= Fq[gamma];
}



void simple_kernel_simulation(int n, const u32 * original_Fq, const u32 * original_Fl)
{
	u32 Fq[561];
	u32 Fl[34];
	
	setup32(n, 1, original_Fq, original_Fl, Fq, Fl);

	/* precompute "derivatives" */
	u32 D[33][33];
	for (int k = L; k < n+1; k++) {
		// constant term
		D[k][0] = Fq[idxq(L-1, k)];

		for (int i = 0; i < L-1; i++)
			D[k][i+1] = Fq[idxq(i, L-1)];
		D[k][L] = 0;
		for (int i = L; i < n; i++)
			D[k][i+1] = Fq[idxq(L-1, i)];
		
		for (int i = 0; i < k; i++)
			D[k][i+1] ^= Fq[idxq(i, k)];
		for (int i = k+1; i < n; i++)
			D[k][i+1] ^= Fq[idxq(k, i)];
	}

	/* check computation of "derivatives" */
	// for (int k = L; k < n; k++) {
	// 	u32 x = 0x1337;
	// 	u32 fx = feslite_naive_evaluation(n+1, Fq, Fl, 1, x);
	// 	u32 y = (1 << (L-1)) ^ (1 << k);
	// 	u32 fy = feslite_naive_evaluation(n+1, Fq, Fl, 1, y);
	// 	u32 fxy = feslite_naive_evaluation(n+1, Fq, Fl, 1, x ^ y);
	// 	assert(D[k][0] == (fy ^ Fl[0]));
	// 	assert(fxy == (fx ^ fy ^ Fl[0] ^ bilinear(n+1, Fq, x, y)));
	// 	assert(gemv(n+2, D[k], x) == (fy ^ Fl[0] ^ bilinear(n+1, Fq, x, y)));
	// 	assert(fxy == (fx ^ gemv(n, D[k], x)));
	// }

	struct ffs_t ffs;
	ffs_reset(&ffs, n-L);
	int k1 = ffs.k1 + L;
	int k2 = ffs.k2 + L;

	assert(k1 == n+1);

	u32 iterations = 1ul << (n - L);
	for (u32 j = 0; j < iterations; j++) {
		u32 i = j << L;

		// save state
		u32 backup[33];
		for (int k = 0; k < n + 1; k++)
			backup[k] = Fl[k];
		
		int alpha = idxq(0, k1);
		ffs_step(&ffs);	
		k1 = ffs.k1 + L;
		k2 = ffs.k2 + L;
		int beta = 1 + k1;
		int gamma = idxq(k1, k2);
	
		UNROLLED_CHUNK(Fq, Fl, alpha, beta, gamma);

		/* check that x has advanced as planned */
		// u32 y = (1 << (L-1)) ^ (1 << k1);
		// assert(to_gray((j+1) << L) == (x ^ y));

		// now, check that we can recompute backup from Fl
		FAST_FORWARD(n, Fq, backup, original_Fl, D, alpha, beta, gamma, i);
		for (int i = 1; i < n+1; i++)
			assert(backup[i] == Fl[i]);
	}
}


int main()
{
	int n = 32;
	mysrand(42);
	u32 Fl[33];
	u32 Fq[496];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33 ; i++)
		Fl[i] = myrand();

	printf("# testing with n=%d and L=%d\n", n, L);
	simple_kernel_simulation(n, Fq, Fl);

	printf("1..1\n");
	printf("ok 1 - I did not crash!\n");

	return 0;
}