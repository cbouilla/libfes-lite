#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */


int main()
{
	int n = 10;
	int k = 24;
	unsigned long random_seed = 1338;

	int n_tests = 1 + feslite_num_kernels();
	printf("1..%d\n", n_tests);

	/*************** setup *****************/
	printf("# initalizing random system with seed=0x%lx\n", random_seed);

	mysrand(random_seed);
	int N = n * (n + 1) / 2;
	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < N; i++)
		Fq[i] = myrand() & ((1 << k) - 1);
	for (int i = 0; i < n + 1; i++)
		Fl[i] = myrand() & ((1 << k) - 1);
	Fl[0] = 0;
	u32 X = myrand() & ((1 << n) - 1); /* designated solution */
	Fl[0] = feslite_naive_evaluation(n, Fq, Fl, X);

	if (feslite_naive_evaluation(n, Fq, Fl, X) == 0)
		printf("ok 1 - feslite_naive_evaluation finds designated solution\n");
	else
		printf("not ok 1 - feslite_naive_evaluation does NOT find designated solution\n");
	printf("# F[%08x] = 0\n", X);

	int count = 256;
	u32 buffer[256];
	
	/******************** go *******************/
	int test_idx = 2;
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		const char *name = feslite_kernel_name(kernel);
		printf("# testing kernel %s\n", name);
		if (!feslite_kernel_is_available(kernel)) {
			printf("ok %d - SKIP / %s not available\n", test_idx++, name);
			continue;
		}

		/* get all solutions */
		bool status = false;
		int size = 0;
		feslite_kernel_solve(kernel, n, 1, Fq, Fl, count, buffer, &size);
		for (int i = 0; i < size; i++) {
			printf("# reporting solution %08x\n", buffer[i]);
			if (buffer[i] == X) {
				status = true;
				break;
			}
		}
		
		if (status)
			printf("ok %d - [%s] expected solution found\n", test_idx++, name);
		else
			printf("not ok %d - [%s] expected solution NOT found\n", test_idx++, name);
	}
	return EXIT_SUCCESS;
}