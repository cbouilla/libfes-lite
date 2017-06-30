#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "feslite.h"
#include "rand.h"

/** test that all the kernels find the same solutions */

int main(int argc, char **argv)
{
	int n = 14;
	int n_eqs = 11;
	int n_iterations = 1;
	unsigned long random_seed = 1;

	size_t n_tests = n_iterations * (kernel_num_available() - 1);
	printf("1..%zd\n", n_tests);

	const size_t N = 1 + n + n * (n - 1) / 2;
	uint32_t *F = calloc(N, sizeof(*F));
	if (!F)
		err(1, "impossible to allocate memory for the coefficients");
	for (size_t i = 0; i < N; i++)
		F[i] = myrand() & ((1ll << n_eqs) - 1);

	size_t max_solutions = 256;
	size_t n_solutions;
	uint32_t *solutions = calloc(max_solutions, sizeof(*F));
	uint32_t *solutions2 = calloc(max_solutions, sizeof(*F));
	if (!solutions || !solutions2)
		err(1, "impossible to allocate memory for the solutions");

	size_t test_idx = 1;
	for (size_t it = 0; it < n_iterations; it++) {

		printf("# initalizing random system with seed=0x%x\n", random_seed);
		mysrand(random_seed++);

		size_t kernel = 0;
		while (1) {
			if (kernel_available(&ENUM_KERNEL[kernel])) {
				printf("# using [%s] to get a first set of solutions\n", ENUM_KERNEL[kernel].name);
				n_solutions = ENUM_KERNEL[kernel].run(n, F, solutions, max_solutions, 0);
				break;
			}
			kernel++;
		}

		printf("# %zd solutions found by [%s] :\n", n_solutions, ENUM_KERNEL[kernel].name);
		for (size_t i = 0; i < n_solutions; i++) {
			uint32_t y = naive_evaluation(n, F, solutions[i]);
			if (y) {
				printf("bail out! - F[%08x] = %08x\n", solutions[i], y);
				exit(0);
			}
			printf("# %08x\n", solutions[i]);
		}

		/* go */
		for (kernel++; kernel < kernel_num(); kernel++) {
			if (!kernel_available(&ENUM_KERNEL[kernel]))
				continue;
			const char *name = ENUM_KERNEL[kernel].name;
			printf("# testing kernel %s\n", name);
		
			/* get all solutions */
			int status = 1;
			size_t n_solutions2 = ENUM_KERNEL[kernel].run(n, F, solutions2, max_solutions, 0);

			printf("# solutions found by [%s]:\n", name);
			for (size_t i = 0; i < n_solutions2; i++)
				printf("# %08x\n", solutions2[i]);
			
			if (n_solutions2 != n_solutions) {
				printf("not ok %zd - [%s] wrong number of solutions (%zd vs %zd)\n", test_idx++, name, n_solutions2, n_solutions);
				continue;
			}

			int ok = 1;
			for (size_t i = 0; i < n_solutions; i++) {
				int found = 0;
				for (size_t j = 0; j < n_solutions; j++) 
					found |= (solutions2[j] == solutions[i]);
				if (!found) {
					printf("not ok %zd - [%s] missing solution %08x\n", test_idx++, name, solutions[i]);
					ok = 0;
				}
				if (!ok)
					break;
			}
			if (ok)
				printf("ok %zd - [%s] solutions match\n", test_idx++, name);
		}
	}

	free(F);
	free(solutions);
	free(solutions2);
	return 0;
}
