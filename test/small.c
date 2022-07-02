#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <assert.h>

#include "fes.h"
#include "rand.h"

/** test that feslite_solve() works correctly on systems with few variables / #lanes */

u32 Fq[496];
int ntest = 0;

void test_size(int n, int m)
{
	int kernel = feslite_choose_kernel(n, m);
	const char *name = feslite_kernel_name(kernel);
	printf("# n=%d and m=%d --> kernel [%s], %d lanes\n", n, m, name, feslite_kernel_batch_size(kernel));
	if (!feslite_kernel_is_available(kernel)) {
		printf("ok %d - SKIP kernel [%s] not available\n", ++ntest, name);
		return;
	}
	
	u32 x[m];
	u32 Fl[(n + 1) * m];
	for (int i = 0; i < (n + 1) * m; i++)
		Fl[i] = myrand();
	for (int k = 0; k < m; k++) {
		x[k] = myrand() & ((1 << n) - 1);        /* designated solution */
		Fl[k] = 0;
		Fl[k] = feslite_naive_evaluation(n, Fq, &Fl[k], m, x[k]);
		printf("# forcing solution %08x in lane %d\n", x[k], k);
		assert(0 == feslite_naive_evaluation(n, Fq, &Fl[k], m, x[k]));
	}

	/* get all solutions */
	int size[m];
	int count = 256;
	u32 buffer[count * m];
	int rc = feslite_solve(n, m, Fq, Fl, count, buffer, size);
	assert(rc == FESLITE_OK);

	for (int k = 0; k < m; k++)
		printf("# kernel [%s] found %d solutions in lane %d:\n", name, size[k], k);

	/* check solutions */
	for (int k = 0; k < m; k++) {
		bool found = false;
		for (int i = 0; i < size[k]; i++) {
			// check solution correctness
			if (0 != feslite_naive_evaluation(n, Fq, &Fl[k], m, buffer[count*k + i])) {
				printf("not ok %d - [%s] reported incorrect solution %08x in lane %d\n", 
					++ntest, name, buffer[count*k + i], k);
				continue;
			}
			printf("# - F[%d][%08x] = 0\n", k, buffer[count*k + i]);
			// did we find the right one?
			found |= (buffer[count*k + i] == x[k]);
		}
		if (found)
			printf("ok %d - [%s] found expected solution in lane %d\n", ++ntest, name, k);
		else
			printf("not ok %d - [%s] did NOT find expected solution in lane %d\n", ++ntest, name, k);
	}
}


int main(int argc, char **argv)

{	
	mysrand(42);
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();

	int LANES[13] = {1, 2, 3, 4, 5, 7, 11, 13, 17, 19, 23, 29, 31};

	for (int n = 2; n < 16; n++)
		for (int k = 0; k < 13; k++) {
			int m = LANES[k];
			test_size(n, m);
		} 
	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}