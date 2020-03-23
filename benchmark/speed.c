#include <stdio.h>
#include <stdlib.h>

#include "fes.h"

int main()
{
	int n = 32;
	int n_eqs = 28;
	unsigned long random_seed = 2;

	srand48(random_seed);

	// initalize a random system
	const int N = 1 + n + n * (n - 1) / 2;
	uint32_t F[N];
	int max_solutions = 256;
	uint32_t solutions[max_solutions];
	for (int i = 0; i < N; i++)
		F[i] = lrand48() & ((1ll << n_eqs) - 1);

	fprintf(stderr, "%d kernels\n", feslite_num_kernels());
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		if (!feslite_kernel_is_available(kernel))
			continue;
		const char *name = feslite_kernel_name(kernel);
		uint64_t start = Now();
		feslite_kernel_solve(kernel, n, F, solutions, max_solutions);
		printf("%s : %.2f cycles/candidate\n", name, (Now() - start) * 1.0 / (1ll << n));
	}
	return EXIT_SUCCESS;
}
