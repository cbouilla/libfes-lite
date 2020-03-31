#include <stdio.h>
#include <stdlib.h>
#include <err.h>

#include "feslite.h"
#include "cycleclock.h"
	
/* Measure raw single-thread speed of all kernels in the library */
int n = 32;


void bench_kernel(int kernel)
{
	const char *name = feslite_kernel_name(kernel);
	if (!feslite_kernel_is_available(kernel)) {
		printf("[%s] is not available on this machine\n", name);
		return;
	}
	int m = feslite_kernel_batch_size(kernel);
	printf("kernel %d [%s] : %d lane... ", kernel, name, m);
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
		
	double rate = ((double) (stop - start)) / m / (1ll << n);
	printf("---> %.2f cycles/candidate / %.2f candidate/cycle\n", rate, 1/rate);
}


int main(int argc, char **argv)
{
	printf("WARNING : for accurate measurement, disable turbo-boost!\n");
	int nkernels = feslite_num_kernels();

	if (argc > 1) {
		int kernel = atoi(argv[1]);
		if (kernel < 0 || kernel >= nkernels)
			errx(1, "bad kernel number");
		bench_kernel(kernel);
	} else {
		for (int kernel = 0; kernel < nkernels; kernel++)
			bench_kernel(kernel);	
	}

	return EXIT_SUCCESS;
}