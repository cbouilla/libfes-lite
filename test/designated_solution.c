#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */


int main()
{
	int n = 24;
	int n_eqs = 24;
	unsigned long random_seed = 1338;

	int n_tests = 1 + feslite_num_kernels();
	printf("1..%d\n", n_tests);

	/*************** setup *****************/
	printf("# initalizing random system with seed=0x%lx\n", random_seed);

	mysrand(random_seed);
	const int N = 1 + n + n * (n - 1) / 2;
	uint32_t F[N];
	for (int i = 1; i < N; i++)
		F[i] = myrand() & ((1 << n_eqs) - 1);
	F[0] = 0;
	uint32_t X = myrand() & ((1 << n) - 1);;
	F[0] = feslite_naive_evaluation(n, F, X);

	if (feslite_naive_evaluation(n, F, X) == 0)
		printf("ok 1 - designated solutions exists\n");
	else
		printf("not ok 1 - designated solutions does NOT exist\n");
	printf("# F[%08x] = 0\n", X);

	int max_solutions = 256;
	uint32_t solutions[max_solutions];
	
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
		int n_solutions =  feslite_kernel_solve(kernel, n, F, solutions, max_solutions, false);
		for (int i = 0; i < n_solutions; i++) {
			printf("# reporting solution %08x\n", solutions[i]);
			if (solutions[i] == X) {
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