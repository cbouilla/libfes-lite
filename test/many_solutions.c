#include <stdbool.h>
#include <stdio.h>
// #include <stdlib.h>

#include "fes.h"
#include "rand.h"

/*
 * test the the kernels correctly report the expected number of solutions,
 * and that reported solutions are both correct and unique.
 */
int ntest = 0;
int n = 22;
int k = 10;
unsigned long random_seed = 1;
u32 Fq[496];
u32 Fl[33];


void test_kernel(int kernel)
{
	if (!feslite_kernel_is_available(kernel))
		return;
	const char *name = feslite_kernel_name(kernel);
	printf("# testing kernel [%s]\n", name);

	/* clone original system in all lanes */
	int m = feslite_kernel_batch_size(kernel);
	u32 Fl2[33 * m];
	for (int i = 0; i < 33; i++)
		for (int j = 0; j < m; j++)
			Fl2[i * m + j] = Fl[i];

	/* run kernel with small solution limit */
	int count = 10;
	u32 buffer[m * count];	
	int size[m];
	feslite_kernel_solve(kernel, n, m, Fq, Fl2, count, buffer, size);
		
	/* check solution number: one lane have reached the cap*/
	bool enough = false;
	for (int lane = 0; lane < m; lane++) {
		printf("# kernel [%s] found %d solutions in lane %d\n", name, size[lane], lane);
		enough |= (size[lane] == count);
	}
	if (!enough)
		printf("not ok %d - kernel [%s] never found %d\n", ++ntest, name, count);
	else
		printf("ok %d - kernel [%s] reach %d solutions\n", ++ntest, name, count);
	
	/* check solutions */
	for (int lane = 0; lane < m; lane++) {
		bool correct = true;
		for (int i = 0; i < size[lane]; i++) {
			u32 y = feslite_naive_evaluation(n, Fq, Fl2, m, buffer[count * lane + i]);
			if (y != 0) {
				printf("not ok %d - kernel [%s] incorrectly reported F[%08x] = %08x in lane %d\n", 
					++ntest, name, buffer[count * lane + i], y, lane);
				correct = false;
				break;
			}
		}
		if (correct)
			printf("ok %d - kernel [%s] reported correct solutions in lane %d\n", 
				++ntest, name, lane);
		
		bool unique = true;
		for (int i = 0; i < size[lane]; i++) 
			for (int j = i + 1; j < size[lane]; j++) {
				if (buffer[count * lane + i] == buffer[count * lane + j]) {
					printf("not ok %d - kernel [%s] returned buffer[%d] = buffer[%d] in lane %d\n", 
						++ntest, name, i, j, lane);
					unique = false;
					i = size[lane];
					break;
				}
			}
		if (unique)
			printf("ok %d - kernel [%s] returned distinct solutions in lane %d\n", ++ntest, name, lane);
	}
}

int main()
{
	printf("# initalizing random system with seed=0x%lx\n", random_seed);
	mysrand(random_seed);
	
	u32 mask = ((1ull << k) - 1) & 0xffffffff;
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand() & mask;
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand() & mask;

	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++)
		test_kernel(kernel);

	printf("1..%d\n", ntest);
	exit(EXIT_SUCCESS);
}