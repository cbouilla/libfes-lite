#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test that all the kernels find the same solutions */

int n = 16;
u32 Fq[496];
int ntest = 0;
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
	u32 Fl[33 * m];
	for (int i = 0; i < 33 * m; i++)
		Fl[i] = 0;
	
	/* get all solutions */
	int size[m];
	int count = 1 << n;
	u32 * buffer = malloc(count * m * sizeof(u32));
	if (buffer == NULL) {
		printf("Bail out! Cannot allocate solution buffer\n");
		exit(1);
	}
	feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
	
	// must reach 1 << n solutions in at least one lane.
	for (int lane = 0; lane < m; lane++) {
		if (size[lane] == count) {
			printf("ok %d - kernel [%s] found the right number of solutions in lane %d\n", ++ntest, name, lane);
			return;
		}
		printf("not ok %d - kernel [%s] never found %d solutions\n", ++ntest, name, count);
	}

	// todo : sort them, check all present.

	
}


int main(int argc, char **argv)

{	
	for (int i = 0; i < 496; i++)
		Fq[i] = 0;

	if (argc > 1) {
		int kernel = feslite_kernel_find_by_name(argv[1]);
		if (kernel < 0)
			return 2;
		test_kernel(kernel);
	} else {
		for (int kernel = 0; kernel < feslite_num_kernels(); kernel++)
			test_kernel(kernel);
	}
	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}