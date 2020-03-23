#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test the the kernels correctly report the expected number of solutions */

int main()
{
	int n = 22;
	int n_eqs = 10;
	unsigned long random_seed = 1;

	int n_tests = 3 * feslite_num_kernels();
	printf("1..%d\n", n_tests);

	printf("# initalizing random system with seed=0x%lx\n", random_seed);
	mysrand(random_seed);

	const int N = 1 + n + n * (n - 1) / 2;
	uint32_t F[N];
	for (int i = 0; i < N; i++)
		F[i] = myrand() & ((1ll << n_eqs) - 1);

	int max_solutions = 1 << 16;
	int n_solutions = 0;
	uint32_t solutions[max_solutions];
	int max_solutions2 = 10;
	uint32_t solutions2[max_solutions2];
	
	/* go */
	int test_idx = 1;
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		if (!feslite_kernel_is_available(kernel))
			continue;
		const char *name = feslite_kernel_name(kernel);
		printf("# testing kernel %s\n", name);
	
		/* get all solutions */
		int status = true;
		n_solutions =  feslite_kernel_solve(kernel, n, F, solutions, max_solutions);
		for (int i = 0; i < n_solutions; i++) {
			uint32_t y = feslite_naive_evaluation(n, F, solutions[i]);
			if (y) {
				printf("not ok %d - [%s] solution %d is a false positive : F[%08x] = %08x\n", test_idx++, name, i, solutions[i], y);
				status = false;
				break;
			}
		}
		if (status) {
			if (n_solutions > 100)
				printf("ok %d - [%s] %d solutions found (enough)\n", test_idx++, name, n_solutions);
			else
				printf("not ok %d - [%s] ONLY %d solutions found (not enough)\n", test_idx++, name, n_solutions);
		}

		/* get the first 10 solutions */
		n_solutions = feslite_kernel_solve(kernel, n, F, solutions2, max_solutions2);
		
		if (n_solutions != max_solutions2)
			printf("not ok %d - [%s] only %d solutions found, %d expected\n", test_idx++, name, n_solutions, max_solutions2);
		else
			printf("ok %d - [%s] %d solutions found\n", test_idx++, name, max_solutions2);
			
		/* compare both */
		status = 1;
		for (int i = 0; i < max_solutions2; i++)
			if (solutions[i] != solutions2[i]) {
				printf("not ok %d - [%s] solution #%d : %08x vs %08x\n", test_idx++, name, i, solutions[i], solutions2[i]);
				status = 0;
				break;
			}
		if (status)
			printf("ok %d - [%s] solutions match\n", test_idx++, name);
	}
	return EXIT_SUCCESS;
}