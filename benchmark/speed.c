#include <stdio.h>
#include <stdlib.h>

#include "fes.h"


int main(/* int argc, char **argv*/)
{
	size_t n = 32;
	size_t n_eqs = 28;
	unsigned long random_seed = 2;

	srand48(random_seed);

	// initalize a random system
	const size_t N = 1 + n + n * (n - 1) / 2;
	uint32_t *F = calloc(N, sizeof(*F));
	if (F == NULL) {
		perror("impossible to allocate memory for the coefficients");
		exit(1);
	}
	size_t max_solutions = 256;
	uint32_t *solutions = calloc(max_solutions, sizeof(*F));
	if (solutions == NULL) {
		perror("impossible to allocate memory for the solutions");
		exit(1);
	}

	for (size_t i = 0; i < N; i++)
		F[i] = lrand48() & ((1ll << n_eqs) - 1);

	fprintf(stderr, "%zd kernels / %zd available\n", feslite_kernel_num(), feslite_kernel_num_available());

	for (size_t kernel = 0; kernel < feslite_kernel_num(); kernel++) {
		if (!feslite_kernel_available(&ENUM_KERNEL[kernel]))
			continue;
		const char *name = ENUM_KERNEL[kernel].name;
		uint64_t start = Now();
		size_t n_solutions = ENUM_KERNEL[kernel].run(n, F, solutions, max_solutions, 0);

		(void) n_solutions;
		/*for (size_t i = 0; i < n_solutions; i++)
			printf("solution %zd : %08x ---> %08x\n", i,
		       solutions[i], naive_evaluation(n, F, solutions[i]));
	
		fprintf(stderr, "%zu solutions\n", n_solutions);*/
		printf("%s : %.2f cycles/candidate\n", name, (Now() - start) * 1.0 / (1ll << n));
	}

	free(F);
	free(solutions);
	return 0;
}
