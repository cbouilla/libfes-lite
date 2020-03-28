#include <assert.h>
#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */


int main()
{
	int n = 20;
	unsigned long random_seed = 1338;

	/*************** setup *****************/
	printf("# initalizing random system with seed=0x%lx\n", random_seed);

	mysrand(random_seed);
	u32 Fq[496];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	
	/******************** go *******************/
	int ntest = 0;
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		if (!feslite_kernel_is_available(kernel))
			continue;
		const char *name = feslite_kernel_name(kernel);
		int m = feslite_kernel_batch_size(kernel);
		printf("# testing kernel [%s], batch_size=%d\n", name, m);
		
		u32 Fl[33 * m];
		u32 x[m];
		for (int i = 0; i < 33 * m; i++)
			Fl[i] = myrand();
		for (int k = 0; k < m; k++) {
			Fl[k] = 0;
			x[k] = myrand() & ((1ull << n) - 1); /* designated solution */
			Fl[k] = feslite_naive_evaluation(n, Fq, &Fl[k], m, x[k]);
			printf("# F[%d][%08x] = 0\n", k, x[k]);
		}

		/* run kernel */
		int size[m];
		int count = 256;
		u32 buffer[count * m];
		feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);

		/* check solutions */
		for (int k = 0; k < m; k++) {
			bool found = false;

			printf("# kernel [%s] found %d solutions in lane %d:\n", name, size[k], k);
			for (int i = 0; i < size[k]; i++) {
				printf(" - F[%d][%08x] = 0\n", k, buffer[count*k + i]);
				found |= (buffer[count*k + i] == x[k]);
			}
			if (found)
				printf("ok %d - [%s] found expected solution in lane %d\n", ntest++, name, k);
			else
				printf("not ok %d - [%s] did NOT find expected solution in lane %d\n", ntest++, name, k);
		}
	}

	printf("1..%d\n", ntest + 1);
	return EXIT_SUCCESS;
}