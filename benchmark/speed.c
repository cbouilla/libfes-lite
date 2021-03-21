#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <err.h>

#include "feslite.h"
#include "cycleclock.h"
	
/* Measure raw single-thread speed of all kernels in the library */
int n = 32;

double wtime() {
	struct timeval ts;
	gettimeofday(&ts, NULL);
	return (double)ts.tv_sec + ts.tv_usec / 1E6;
}


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
	u32 Fl[34 * m];
	for (int i = 0; i < 496; i++)
		Fq[i] = lrand48();
	for (int i = 0; i < 34 * m; i++)
		Fl[i] = 0;
	for (int i = 0; i < (n+1) * m; i++)
		Fl[i] = lrand48();
	
	/* run kernel */
	int count = 256;
	u32 buffer[count * m];
	int size[m];
	double start_wt = wtime();
	u64 start = Now();
	feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
	u64 stop = Now();
	double stop_wt = wtime();

	double cycles = stop - start;
	double seconds = stop_wt - start_wt;
	double rate = cycles / m / (1ll << n);
	printf("\t---> %.2f s\n", stop_wt - start_wt);
	printf("\t---> %.2f cycles/candidate || %.2f candidate/cycle\n", rate, 1/rate);
	printf("\t---> 2^%.2f candidate/s\n", log2(m) + n - log2(seconds));
}


int main(int argc, char **argv)
{
	printf("WARNING : for accurate measurement, disable turbo-boost!\n");
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