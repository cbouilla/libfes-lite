#include <stdio.h>
#include <stdlib.h>

#include "feslite.h"
#include "cycleclock.h"
	
/* Measure raw speed of all kernels in the library */

int main()
{
	int n = 32;
	
	/* query the library */
	int nkernels = feslite_num_kernels();
	printf("%d kernels\n", nkernels);
	
	for (int kernel = 0; kernel < nkernels; kernel++) {
		const char *name = feslite_kernel_name(kernel);
		if (!feslite_kernel_is_available(kernel)) {
			printf("[%s] is not available on this machine\n", name);
			continue;
		}
		int m = feslite_kernel_batch_size(kernel);
		printf("[%s] : %d lane... ", name, m);
		fflush(stdout);

		srand48(1337);
	
		/* initalize m random related systems */	
		u32 Fq[496];
		u32 Fl[33 * m];
		for (int i = 0; i < 496; i++)
			Fq[i] = lrand48();
		for (int i = 0; i < 33 * m; i++)
			Fl[i] = lrand48();
	
		/* run kernel */
		int count = 256;
		u32 buffer[count * m];
		int size[m];
		u64 start = Now();
		feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
		u64 stop = Now();
		
		printf("---> %.2f cycles/candidate\n", ((double) (stop - start)) / m / (1ll << n));
	}

	return EXIT_SUCCESS;
}