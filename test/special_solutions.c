#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "rand.h"

#define N 42

u32 test_cases[N] = {
        0x80000000, 0x40000000, 0x20000000, 0x10000000,
        0x08000000, 0x04000000, 0x02000000, 0x01000000,
        0x00800000, 0x00400000, 0x00200000, 0x00100000,
        0x00080000, 0x00040000, 0x00020000, 0x00010000,
        0x00008000, 0x00004000, 0x00002000, 0x00001000,
        0x00000800, 0x00000400, 0x00000200, 0x00000100,
        0x00000080, 0x00000040, 0x00000020, 0x00000010,
        0x00000008, 0x00000004, 0x00000002, 0x00000001,
	0x00000000, 0xffffffff, 0xffff0000, 0x0000ffff, 
        0xff00ff00, 0x00ff00ff, 0x0f0f0f0f, 0xf0f0f0f0, 
        0x55555555, 0xcccccccc
};

int main()
{
	int n = 24; // fast version
	unsigned long random_seed = 1337;
	printf("# initalizing random systems with seed=0x%lx\n", random_seed);
	mysrand(random_seed);

	int n_tests = N * feslite_num_kernels();
	int testidx = 1;

	u32 Fq[496];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();

	/******************** go *******************/
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		const char *name = feslite_kernel_name(kernel);
		printf("# testing kernel [%s]\n", name);

		if (!feslite_kernel_is_available(kernel)) {
			printf("ok %d - SKIP kernel [%s] not available\n", testidx++, name);
			continue;
		}

		int m = feslite_kernel_batch_size(kernel);
		u32 Fl[33 * m];
		int count = 256;
		u32 buffer[count * m];
		int size[m];

		for (int k = 0; k < N; k++) {
			// prepare system with special solution on lane 0
			for (int i = 0; i < 33 * m; i++)
				Fl[i] = myrand();
			u32 x = test_cases[k] & ((1ull << n) - 1);
			Fl[0] = 0;
			Fl[0] = feslite_naive_evaluation(n, Fq, Fl, m, x);

			feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
			if (size[0] < 0) {
				printf("not ok %d - kernel [%s] failed\n", testidx++, name);
				continue;
			}

			bool found = false;
			for (int i = 0; i < size[0]; i++)
				found |= (buffer[i] == x);
		
			if (found)
				printf("ok %d - kernel [%s] found expected solution %08x\n", testidx++, name, test_cases[k]);
			else
				printf("not ok %d - kernel [%s] did NOT find expected solution %08x\n", testidx++, name, test_cases[k]);
		}	
	}
	printf("1..%d\n", n_tests);
	return EXIT_SUCCESS;
}