#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <err.h>
#include <omp.h>
#include <assert.h>

#include "feslite.h"
#include "cycleclock.h"
	
/* Measure raw multi-threaded-thread speed of all kernels in the library */
int n = 32;
int T = -1;

void bench_kernel(int kernel)
{
	const char *name = feslite_kernel_name(kernel);
	if (!feslite_kernel_is_available(kernel)) {
		printf("[%s] is not available on this machine\n", name);
		return;
	}
	int m = feslite_kernel_batch_size(kernel);
	printf("kernel %d [%s] : %d lane(s)...\n", kernel, name, m);
	fflush(stdout);

	srand48(1337);
	/* initalize m random related systems */	
	u32 Fq[496];
	for (int i = 0; i < 496; i++)
		Fq[i] = lrand48();
	
	double start_wt = omp_get_wtime();
	u64 start = Now();
	int count = 256;

	#pragma omp parallel
	{
		assert(omp_get_num_threads() == T);
		u32 Fl[33 * m];
		for (int i = 0; i < 33 * m; i++)
			Fl[i] = lrand48();
		u32 buffer[count * m];
		int size[m];
		feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
	}
	u64 stop = Now();
	double stop_wt = omp_get_wtime();

	double cycles = stop - start;
	double seconds = stop_wt - start_wt;
	double rate = cycles / m / (1ll << n);
	printf("\t---> %.2f s\n", stop_wt - start_wt);
	printf("\t---> %.2f cycles/candidate || %.2f candidate/cycle\n", rate, 1/rate);
	printf("\t---> 2^%.2f candidate/s on all threads\n", log2(m) + n + log2(T) - log2(seconds));
}


int main(int argc, char **argv)
{
	T = omp_get_max_threads();
	printf("INFO    : running with %d threads\n", T);
	int nkernels = feslite_num_kernels();

	if (argc > 1) {
		int kernel = feslite_kernel_find_by_name(argv[1]);
		if (kernel < 0)
			errx(1, "bad kernel name (use ./list)");
		bench_kernel(kernel);
	} else {
		for (int kernel = 0; kernel < nkernels; kernel++)
			bench_kernel(kernel);	
	}

	return EXIT_SUCCESS;
}