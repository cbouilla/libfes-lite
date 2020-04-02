#include <assert.h>
#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */

int n = 20;
unsigned long random_seed = 1338;
u32 Fq[496];
int ntest = 0;

void test_kernel(int kernel)
{
	if (!feslite_kernel_is_available(kernel))
		return;
	const char *name = feslite_kernel_name(kernel);
	int m = feslite_kernel_batch_size(kernel);
	printf("# testing kernel [%s], batch_size=%d\n", name, m);

		
	u32 Fl[33 * m];
	u32 x[m];
	
	mysrand(1337);
	for (int k = 0; k < m; k++) {
		for (int i = 1; i < 33 ; i++)
			Fl[k + m*i] = myrand();
		
		Fl[k] = 0;
		x[k] = myrand() & ((1ull << n) - 1); /* designated solution */
		Fl[k] = feslite_naive_evaluation(n, Fq, &Fl[k], m, x[k]);
		printf("# forcing solution %08x in lane %d\n", x[k], k);
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
			// check solution correctness
			if (0 != feslite_naive_evaluation(n, Fq, &Fl[k], m, buffer[count*k + i])) {
				printf("not ok %d - [%s] reported incorrect solution %08x in lane %d\n", 
					++ntest, name, buffer[count*k + i], k);
				continue;
			}
			printf("# - F[%d][%08x] = 0\n", k, buffer[count*k + i]);
			// did we find the right one?
			found |= (buffer[count*k + i] == x[k]);
		}
		if (found)
			printf("ok %d - [%s] found expected solution in lane %d\n", ++ntest, name, k);
		else
			printf("not ok %d - [%s] did NOT find expected solution in lane %d\n", ++ntest, name, k);
	}
}

int main(int argc, char **argv)
{	
	mysrand(42);
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();

	if (argc > 1) {
		int kernel = feslite_kernel_find_by_name(argv[1]);
		if (kernel < 0)
			return 2;
		test_kernel(kernel);
	} else {
		/* no argument : test everything */
		for (int kernel = 0; kernel < feslite_num_kernels(); kernel++)
			test_kernel(kernel);
	}
	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}