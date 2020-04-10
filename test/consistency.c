#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test that all the kernels find the same solutions */

int n = 24;
int k = 21;
unsigned long random_seed = 1;
u32 Fq[496];
u32 Fl[34];
int ntest = 0;
u32 buffer[256];
int size;

void test_kernel(int kernel)
{
	const char *name = feslite_kernel_name(kernel);
	printf("# testing kernel [%s]\n", name);
	if (!feslite_kernel_is_available(kernel)) {
		printf("ok %d - SKIP kernel [%s] not available\n", ++ntest, name);
		return;
	}
	
	/* clone original system in all lanes */
	int m = feslite_kernel_batch_size(kernel);
	u32 Fl2[33 * m];
	for (int i = 0; i < 33; i++)
		for (int j = 0; j < m; j++)
			Fl2[i * m + j] = Fl[i];
	
	/* get all solutions */
	int size2[m];
	u32 buffer2[256 * m];
	feslite_kernel_solve(kernel, n, m, Fq, Fl2, 256, buffer2, size2);
	
	bool ok = true;
	for (int lane = 0; lane < m; lane++) {
		printf("# %d solutions found by [%s] on lane %d:\n", size2[lane], name, lane);
		for (int i = 0; i < size2[lane]; i++)
			printf("# - F[%d][%08x] == 0\n", lane, buffer2[i]);
		
		if (size != size2[lane]) {
			printf("not ok %d - kernel [%s] found %d solutions in lane %d (vs %d expected)\n",
				++ntest, name, size2[lane], lane, size);
			continue;
		}
	
		/* check inclusion */
		for (int i = 0; i < size; i++) {
			bool found = false;
			for (int j = 0; j < size2[lane]; j++) 
				found |= (buffer2[256 * lane + j] == buffer[i]);
			if (!found) {
				printf("not ok %d - kernel [%s] is missing solution %08x in lane %d\n", 
					++ntest, name, buffer[i], lane);
				ok = false;
				break;
			}
		}
		if (ok)
			printf("ok %d - kernel [%s] found all the solutions in lane %d\n", ++ntest, name, lane);
	}
}

int main(int argc, char **argv)
{	
	printf("# initalizing random system with seed=0x%lx\n", random_seed);
	mysrand(random_seed++);

	u32 mask = ((1ull << k) - 1) & 0xffffffff;
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand() & mask;
	for (int i = 0; i < n+1; i++)
		Fl[i] = myrand() & mask;
	Fl[n + 1] = 0;

	printf("# using kernel [%s] to get a first set of solutions\n", feslite_kernel_name(0));
	if (!feslite_kernel_is_available(0)) {
		printf("Bail out! Kernel ZERO is not available. What on earth...\n");
		exit(EXIT_SUCCESS);
	}

	if (feslite_kernel_batch_size(0) != 1) {
		printf("Bail out! Kernel ZERO has batch_size > 1...\n");
		exit(EXIT_SUCCESS);
	}
			
	feslite_kernel_solve(0, n, 1, Fq, Fl, 256, buffer, &size);
	printf("# %d solutions found\n", size);
	
	/* go */
	if (argc > 1) {
		int kernel = feslite_kernel_find_by_name(argv[1]);
		if (kernel < 0)
			return 2;
		test_kernel(kernel);
	} else {
		/* no argument : test everything */
		for (int kernel = 1; kernel < feslite_num_kernels(); kernel++)
			test_kernel(kernel);
	}

	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}