#include <stdio.h>
#include <assert.h>

/* 
 * check that the counter advance correctly
 */		


#include "rand.h"
#include "fes.h"

#define L 8


void simple_kernel_simulation(int n)
{
	struct ffs_t ffs;
	ffs_reset(&ffs, n-L);
	int k1 = ffs.k1 + L;
	
	assert(k1 == n+1);
	assert(ffs.k2 == -1);

	u32 iterations = 1ul << (n - L);
	for (u32 j = 0; j < iterations; j++) {
		u32 x = to_gray(j << L);
		ffs_step(&ffs);	

		/* check ffs */
		u32 target = j + 1 + (1 << (n-L+1));
		assert(ffs.k1 == __builtin_ffs(target) - 1);
		assert(ffs.k2 == __builtin_ffs(target & (target-1)) - 1);

		/* check that x advances as planned */
		int k1 = ffs.k1 + L;
		u32 y = (1 << (L-1)) ^ (1 << k1);
		assert(to_gray((j+1) << L) == (x ^ y));
	}
}


int main()
{
	int n = 24;

	simple_kernel_simulation(n);

	printf("1..1\n");
	printf("ok 1 - I did not crash!\n");

	return 0;
}