#include <stdio.h>
#include <stdlib.h>

#include "feslite.h"
#include "cycleclock.h"

/* demonstrates the correct use of the library */

int main()
{
	int n = 32;
	int n_eqs = 28;
	unsigned long random_seed = 2;
	srand48(random_seed);

	/* initalize a random system */	
	const int N = 1 + n + n * (n - 1) / 2;
	uint32_t F[N];
	int max_solutions = 256;
	uint32_t solutions[max_solutions];
	
	for (int i = 0; i < N; i++)
		F[i] = lrand48() & ((1ll << n_eqs) - 1);

	/* solve */
	uint64_t start = Now();
	int n_solutions = feslite_solve(n, F, solutions, max_solutions);
	
	/* report */
	int kernel = feslite_default_kernel();
	const char *name = feslite_kernel_name(kernel);
	printf("%s : %d solutions found, %.2f cycles/candidate\n", name, 
		n_solutions, (Now() - start) * 1.0 / (1ll << n));
	
	return EXIT_SUCCESS;
}