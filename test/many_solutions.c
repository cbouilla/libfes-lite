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

	size_t n_tests = 3 * feslite_kernel_num_available();
	printf("1..%zd\n", n_tests);

	printf("# initalizing random system with seed=0x%lx\n", random_seed);

	mysrand(random_seed);
	const size_t N = 1 + n + n * (n - 1) / 2;
	uint32_t *F = calloc(N, sizeof(*F));
	if (!F)
		err(1, "impossible to allocate memory for the coefficients");
	for (size_t i = 0; i < N; i++)
		F[i] = myrand() & ((1ll << n_eqs) - 1);

	size_t max_solutions = 1 << 16;
	size_t n_solutions;
	uint32_t *solutions = calloc(max_solutions, sizeof(*F));
	if (!solutions)
		err(1, "impossible to allocate memory for the solutions");
	
	size_t max_solutions2 = 10;
	uint32_t *solutions2 = calloc(max_solutions2, sizeof(*F));
	if (!solutions2)
		err(1, "impossible to allocate memory for the solutions");

	/* go */
	size_t test_idx = 1;
	for (size_t kernel = 0; kernel < feslite_kernel_num(); kernel++) {
		if (!feslite_kernel_available(&ENUM_KERNEL[kernel]))
			continue;
		const char *name = ENUM_KERNEL[kernel].name;
		printf("# testing kernel %s\n", name);
	

		/* get all solutions */
		int status = 1;
		n_solutions =  ENUM_KERNEL[kernel].run(n, F, solutions, max_solutions, 0);
		for (size_t i = 0; i < n_solutions; i++) {
			uint32_t y = feslite_naive_evaluation(n, F, solutions[i]);
			if (y) {
				printf("not ok %zd - [%s] solution #%zd : F[%08x] = %08x\n", test_idx++, name, i, solutions[i], y);
				status = 0;
				break;
			}
		}
		if (status) {
			if (n_solutions > 100)
				printf("ok %zd - [%s] %zd solutions found\n", test_idx++, name, n_solutions);
			else
				printf("not ok %zd - [%s] ONLY %zd solutions found\n", test_idx++, name, n_solutions);
		}

		/* get the first 10 solutions */
		n_solutions = ENUM_KERNEL[kernel].run(n, F, solutions2, max_solutions2, 0);
		
		if (n_solutions != max_solutions2)
			printf("not ok %zd - [%s] only %zd solutions found, %zd expected\n", test_idx++, name, n_solutions, max_solutions2);
		else
			printf("ok %zd - [%s] %zd solutions found\n", test_idx++, name, max_solutions2);
			
		/* compare both */
		status = 1;
		for (size_t i = 0; i < max_solutions2; i++)
			if (solutions[i] != solutions2[i]) {
				printf("not ok %zd - [%s] solution #%zd : %08x vs %08x\n", test_idx++, name, i, solutions[i], solutions2[i]);
				status = 0;
				break;
			}
		if (status)
			printf("ok %zd - [%s] solutions match\n", test_idx++, name);
	}

	free(F);
	free(solutions);
	free(solutions2);
	return 0;
}
