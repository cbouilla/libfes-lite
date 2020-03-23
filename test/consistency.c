#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test that all the kernels find the same solutions */

int main()
{
	int n = 24;
	int n_eqs = 21;
	int n_iterations = 1;
	unsigned long random_seed = 1;

	int n_tests = n_iterations * (feslite_num_kernels() - 1);
	printf("1..%d\n", n_tests);

	const int N = 1 + n + n * (n - 1) / 2;
	uint32_t F[N];
	for (int i = 0; i < N; i++)
		F[i] = myrand() & ((1ll << n_eqs) - 1);

	int max_solutions = 256;
	int n_solutions = 0;
	uint32_t solutions[max_solutions];
	uint32_t solutions2[max_solutions];
	
	int test_idx = 1;
	for (int it = 0; it < n_iterations; it++) {

		printf("# initalizing random system with seed=0x%lx\n", random_seed);
		mysrand(random_seed++);

		int kernel;
		for (kernel = 0; kernel < feslite_num_kernels(); kernel++) {
			if (feslite_kernel_is_available(kernel)) {
				printf("# using [%s] to get a first set of solutions\n", ENUM_KERNEL[kernel].name);
				n_solutions = feslite_kernel_solve(kernel, n, F, solutions, max_solutions);
				break;
			}
		}

		printf("# %d solutions found by [%s]:\n", n_solutions, feslite_kernel_name(kernel));
		for (int i = 0; i < n_solutions; i++) {
			uint32_t y = feslite_naive_evaluation(n, F, solutions[i]);
			if (y) {
				printf("bail out! - F[%08x] = %08x\n", solutions[i], y);
				exit(0);
			}
			printf("# %08x\n", solutions[i]);
		}

		/* go */
		for (kernel += 1; kernel < feslite_num_kernels(); kernel++) {
			if (!feslite_kernel_is_available(kernel))
				continue;
			const char *name = feslite_kernel_name(kernel);
			printf("# testing kernel %s\n", name);
		
			/* get all solutions */
			int n_solutions2 = feslite_kernel_solve(kernel, n, F, solutions2, max_solutions);

			printf("# solutions found by [%s]:\n", name);
			for (int i = 0; i < n_solutions2; i++)
				printf("# %08x\n", solutions2[i]);
			
			if (n_solutions2 != n_solutions) {
				printf("not ok %d - [%s] wrong number of solutions (%d vs %d)\n", test_idx++, name, n_solutions2, n_solutions);
				continue;
			}

			int ok = 1;
			for (int i = 0; i < n_solutions; i++) {
				int found = 0;
				for (int j = 0; j < n_solutions; j++) 
					found |= (solutions2[j] == solutions[i]);
				if (!found) {
					printf("not ok %d - [%s] missing solution %08x\n", test_idx++, name, solutions[i]);
					ok = 0;
				}
				if (!ok)
					break;
			}
			if (ok)
				printf("ok %d - [%s] solutions match\n", test_idx++, name);
		}
	}
	return EXIT_SUCCESS;
}