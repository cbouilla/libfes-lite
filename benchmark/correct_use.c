#include <stdio.h>
#include <stdlib.h>

#include "feslite.h"
#include "cycleclock.h"

/* demonstrates the correct use of the library */

int main()
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

	/* solve */
	uint64_t start = Now();
	size_t n_solutions = feslite_solve(n, F, solutions, max_solutions, true);
	
	/* report */
	printf("%s : %zd solutions found, %.2f cycles/candidate\n", feslite_solver_name(), 
		n_solutions, (Now() - start) * 1.0 / (1ll << n));
	
	free(F);
	free(solutions);
	return EXIT_SUCCESS;
}
