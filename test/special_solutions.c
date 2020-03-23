#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "rand.h"

#define N 10

/* uint32_t test_cases[32] = {
        0x80000000, 0x40000000, 0x20000000, 0x10000000,
        0x08000000, 0x04000000, 0x02000000, 0x01000000,
        0x00800000, 0x00400000, 0x00200000, 0x00100000,
        0x00080000, 0x00040000, 0x00020000, 0x00010000,
        0x00008000, 0x00004000, 0x00002000, 0x00001000,
        0x00000800, 0x00000400, 0x00000200, 0x00000100,
        0x00000080, 0x00000040, 0x00000020, 0x00000010,
        0x00000008, 0x00000004, 0x00000002, 0x00000001,
};*/

static uint32_t test_cases[N] = {
	//0x00000000, 0xffffffff, 0xffff0000, 0x0000ffff, 
        //0xff00ff00, 0x00ff00ff, 0x0f0f0f0f, 0xf0f0f0f0, 
        //0x55555555, 0xcccccccc
        0x00000000, 0x0fffffff, 0x0fff0000, 0x0000ffff, 
	0x0f00ff00, 0x00ff00ff, 0x0f0f0f0f, 0x00f0f0f0, 
	0x05555555, 0x0ccccccc
};

int main()
{
	int n = 28; // fast version
	unsigned long random_seed = 1337;
	printf("# initalizing random systems with seed=0x%lx\n", random_seed);
	mysrand(random_seed);

	int n_tests = N * feslite_num_kernels();
	printf("1..%d\n", n_tests);
	int test_idx = 1;
	
	for (int k = 0; k < N; k++) {
		printf("# initalizing random systems with seed=0x%lx\n", random_seed);

		/*************** setup *****************/
		const int size = 1 + n + n * (n - 1) / 2;
		uint32_t F[size];
		for (int i = 1; i < size; i++)
			F[i] = myrand();
		F[0] = 0;
		F[0] = feslite_naive_evaluation(n, F, test_cases[k]);
		assert(feslite_naive_evaluation(n, F, test_cases[k]) == 0);
		
		int max_solutions = 256;
		uint32_t solutions[max_solutions];
		
		/******************** go *******************/
		for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
			const char *name = feslite_kernel_name(kernel);
			printf("# testing kernel %s\n", name);

			if (!feslite_kernel_is_available(kernel)) {
				printf("ok %d - SKIP [%s] kernel not available\n", test_idx++, name);
				continue;
			}

			/* get all solutions */
			bool status = false;
			int n_solutions =  feslite_kernel_solve(kernel, n, F, solutions, max_solutions, 0);
			for (int i = 0; i < n_solutions; i++) {
				printf("# reporting solution %08x\n", solutions[i]);
				if (solutions[i] == test_cases[k]) {
					status = true;
					break;
				}
			}
		
			if (status)
				printf("ok %d - [%s] expected solution found\n", test_idx++, name);
			else
				printf("not ok %d - [%s] expected solution NOT found\n", test_idx++, name);
		}	
	}
	return EXIT_SUCCESS;
}