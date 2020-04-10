#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"
#include "rand.h"

int n = 24; // fast version

u32 test_cases[] = {
        0x80000000, 0x40000000, 0x20000000, 0x10000000,
        0x08000000, 0x04000000, 0x02000000, 0x01000000,
        0x00800000, 0x00400000, 0x00200000, 0x00100000,
        0x00080000, 0x00040000, 0x00020000, 0x00010000,
        0x00008000, 0x00004000, 0x00002000, 0x00001000,
        0x00000800, 0x00000400, 0x00000200, 0x00000100,
        0x00000080, 0x00000040, 0x00000020, 0x00000010,
        0x00000008, 0x00000004, 0x00000002, 0x00000001,

	0x00000003, 0x00000006, 0x0000000c, 0x00000018, 
	0x00000030, 0x00000060, 0x000000c0, 0x00000180, 
	0x00000300, 0x00000600, 0x00000c00, 0x00001800, 
	0x00003000, 0x00006000, 0x0000c000, 0x00018000, 
	0x00030000, 0x00060000, 0x000c0000, 0x00180000, 
	0x00300000, 0x00600000, 0x00c00000, 0x01800000, 
	0x03000000, 0x06000000, 0x0c000000, 0x18000000, 
	0x30000000, 0x60000000, 0xc0000000, 

	0x00000002, 0x00000005, 0x0000000b, 0x00000017, 
	0x0000002f, 0x0000005f, 0x000000bf, 0x0000017f, 
	0x000002ff, 0x000005ff, 0x00000bff, 0x000017ff, 
	0x00002fff, 0x00005fff, 0x0000bfff, 0x00017fff, 
	0x0002ffff, 0x0005ffff, 0x000bffff, 0x0017ffff, 
	0x002fffff, 0x005fffff, 0x00bfffff, 0x017fffff, 
	0x02ffffff, 0x05ffffff, 0x0bffffff, 0x17ffffff, 
	0x2fffffff, 0x5fffffff, 0xbfffffff, 

	0x00000000, 0xffffffff, 0xffff0000, 0x0000ffff, 
        0xff00ff00, 0x00ff00ff, 0x0f0f0f0f, 0xf0f0f0f0, 
        0x55555555, 0xcccccccc
};


unsigned long random_seed = 1337;
int ntest = 0;
u32 Fq[496];
	

void test_kernel(int kernel, int k)
{
	if (!feslite_kernel_is_available(kernel))
		return;

	const char *name = feslite_kernel_name(kernel);

	int m = feslite_kernel_batch_size(kernel);
	u32 Fl[34 * m];
	int count = 256;
	u32 buffer[count * m];
	int size[m];

	// prepare system with special solution on lane 0
	for (int i = 0; i < 34 * m; i++)
		Fl[i] = 0;
	for (int i = 0; i < (n+1) * m; i++)
		Fl[i] = myrand();
	
	u32 x = test_cases[k] & ((1ull << n) - 1);
	Fl[0] = 0;
	Fl[0] = feslite_naive_evaluation(n, Fq, Fl, m, x);

	feslite_kernel_solve(kernel, n, m, Fq, Fl, count, buffer, size);
	if (size[0] < 0) {
		printf("not ok %d - kernel [%s] failed\n", ++ntest, name);
		return;
	}

	bool found = false;
	for (int i = 0; i < size[0]; i++) {
		if (0 != feslite_naive_evaluation(n, Fq, Fl, m, buffer[i])) {
			printf("not ok %d - [%s] reported incorrect solution %08x in lane 0\n", 
				++ntest, name, buffer[count*k + i]);
			return;
		}
		printf(" - F[0][%08x] = 0\n", buffer[i]);
		found |= (buffer[i] == x);
	}
	
	if (found)
		printf("ok %d - kernel [%s] found expected solution %08x in lane 0\n", 
			++ntest, name, test_cases[k]);
	else
		printf("not ok %d - kernel [%s] did NOT find expected solution %08x in lane 0\n", 
			++ntest, name, test_cases[k]);
}

int main(int argc, char **argv)
{
	printf("# testing with n = %d\n", n);
	printf("# initalizing random systems with seed=0x%lx\n", random_seed);
	mysrand(random_seed);

	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();

	int N = sizeof(test_cases) / sizeof(u32);

	if (argc > 1) {
		int kernel = feslite_kernel_find_by_name(argv[1]);
		if (kernel < 0)
			return 2;
		for (int i = 0; i < N; i++)
			test_kernel(kernel, i);
	} else {
		/* no argument : test everything */
		for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
			const char *name = feslite_kernel_name(kernel);		
			printf("# testing kernel [%s]\n", name);
			for (int i = 0; i < N; i++)
				test_kernel(kernel, i);
		}
	}

	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}