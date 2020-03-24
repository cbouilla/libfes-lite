#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test that all the kernels find the same solutions */

int main()
{
	int n = 24;
	int k = 21;
	unsigned long random_seed = 1;

	int n_tests = feslite_num_kernels() - 1;
	printf("1..%d\n", n_tests);

	u32 Fq[496];
	u32 Fl[33];
	u32 mask = ((1ull << k) - 1) & 0xffffffff;
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand() & mask;
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand() & mask;

	
	u32 buffer1[256];
	u32 buffer2[256];
	
	int test_idx = 1;
	

	printf("# initalizing random system with seed=0x%lx\n", random_seed);
	mysrand(random_seed++);

	int kernel;
	int size = 0;
	for (kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		if (feslite_kernel_is_available(kernel)) {
			printf("# using kernel [%s] to get a first set of solutions\n", feslite_kernel_name(kernel));
			feslite_kernel_solve(kernel, n, 1, Fq, Fl, 256, buffer1, &size);
			break;
		}
	}

	printf("# %d solutions found by [%s]:\n", size, feslite_kernel_name(kernel));
	
	/* check correctness of solutions */
	for (int i = 0; i < size; i++) {
		u32 y = feslite_naive_evaluation(n, Fq, Fl, buffer1[i]);
		if (y) {
			printf("bail out! - F[%08x] = %08x\n", buffer1[i], y);
			exit(0);
		}
		printf("# %08x\n", buffer1[i]);
	}

	/* go */
	for (kernel += 1; kernel < feslite_num_kernels(); kernel++) {
		if (!feslite_kernel_is_available(kernel))
			continue;

		const char *name = feslite_kernel_name(kernel);
		printf("# testing kernel [%s]\n", name);
	
		/* get all solutions */
		int size2 = 0;
		feslite_kernel_solve(kernel, n, 1, Fq, Fl, 256, buffer2, &size2);
		printf("# %d solutions found by [%s]:\n", size2, name);
		for (int i = 0; i < size2; i++)
			printf("# - %08x\n", buffer2[i]);
		
		if (size != size2) {
			printf("not ok %d - kernel [%s] found wrong number of solutions (%d vs %d expected)\n", 
				test_idx++, name, size2, size);
			continue;
		}

		/* check inclusion */
		bool ok = true;
		for (int i = 0; i < size; i++) {
			bool found = false;
			for (int j = 0; j < size; j++) 
				found |= (buffer2[j] == buffer1[i]);
			if (!found) {
				printf("not ok %d - kernel [%s] is missing solution %08x\n", test_idx++, name, buffer1[i]);
				ok = false;
				break;
			}
		}
		if (ok)
			printf("ok %d - kernel [%s] found all the solutions\n", test_idx++, name);
	}
	
	return EXIT_SUCCESS;
}