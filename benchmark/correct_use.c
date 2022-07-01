#include <stdio.h>
#include <stdlib.h>

#include "feslite.h"
#include "cycleclock.h"

/* 
 * Demonstrate the correct use of the library.
 *  - Ask what is the preferred batch size (m)
 *  - Build m related systems of k quadratic boolean equations in n variables.
 *  - Solve the m systems at once
 */

int main()
{
	int n = 32;
	int k = 28;
	unsigned long random_seed = 2;
	srand48(random_seed);

	/* query the library */
	int m = feslite_preferred_batch_size();

	/* initalize m random related systems */	
	u32 Fq[561];
	u32 Fl[34 * m];
	for (int i = 0; i < 561; i++)
		Fq[i] = lrand48() & ((1ll << k) - 1);
	for (int i = 0; i < 34 * m; i++)
		Fl[i] = lrand48() & ((1ll << k) - 1);

	/* solve */
	u32 solutions[256 * m];   /* solution buffer of size 256 */
	int size[m];
	uint64_t start = Now();
	feslite_solve(n, m, Fq, Fl, 256, solutions, size);
	uint64_t stop = Now();

	/* report */
	int kernel = feslite_default_kernel();
	const char *name = feslite_kernel_name(kernel);
	printf("%s : %d lanes, %.2f cycles/candidate\n", 
		name, m, ((double) (stop - start)) / m / (1ll << n));
	for (int i = 0; i < m; i++)
	printf("Lane %d : %d solutions found\n", i, size[i]);
	
	return EXIT_SUCCESS;
}