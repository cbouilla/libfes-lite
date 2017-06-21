#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "feslite.h"
#include "rand.h"

/** create a random system with a known solution,
	then test that the kernels correctly find this solution. */


int main(int argc, char **argv)
{
	int n = 24;
	int n_eqs = 24;
	unsigned long random_seed = 1338;



	size_t n_tests = 1 + kernel_num_available();
	printf("1..%zd\n", n_tests);

	/*************** setup *****************/
	printf("# initalizing random system with seed=0x%x\n", random_seed);

	mysrand(random_seed);
	const size_t N = 1 + n + n * (n - 1) / 2;
	uint32_t *F = calloc(N, sizeof(*F));
	if (!F)
		err(1, "impossible to allocate memory for the coefficients");
	for (size_t i = 1; i < N; i++)
		F[i] = myrand() & ((1 << n_eqs) - 1);
	F[0] = 0;
	uint32_t X = myrand() & ((1 << n) - 1);;
	F[0] = naive_evaluation(n, F, X);

	if (naive_evaluation(n, F, X) == 0)
		printf("ok 1 - designated solutions exists\n");
	else
		printf("not ok 1 - designated solutions does NOT exist\n");

	printf("# F[%08x] = 0\n", X);

	size_t max_solutions = 256;
	size_t n_solutions;
	uint32_t *solutions = calloc(max_solutions, sizeof(*F));
	if (!solutions)
		err(1, "impossible to allocate memory for the solutions");
	
	/******************** go *******************/
	size_t test_idx = 2;
	for (size_t kernel = 0; kernel < kernel_num(); kernel++) {
		if (!kernel_available(&ENUM_KERNEL[kernel]))
			continue;
		const char *name = ENUM_KERNEL[kernel].name;
		printf("# testing kernel %s\n", name);

		/* get all solutions */
		int status = 0;
		n_solutions =  ENUM_KERNEL[kernel].run(n, F, solutions, max_solutions, 0);
		for (size_t i = 0; i < n_solutions; i++) {
			printf("# reporting solution %08x\n", solutions[i]);
			if (solutions[i] == X) {
				status = 1;
				break;
			}
		}
		
		if (status)
			printf("ok %zd - [%s] expected solution found\n", test_idx++, name);
		else
			printf("not ok %zd - [%s] expected solution NOT found\n", test_idx++, name);
	}

	free(F);
	free(solutions);
	return 0;
}
