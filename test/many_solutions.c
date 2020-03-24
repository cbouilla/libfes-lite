#include <stdbool.h>
#include <stdio.h>
// #include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** test the the kernels correctly report the expected number of solutions */

bool check_correctness(int test, const char *name, int n, u32 *Fq, u32 *Fl, int size, u32 *buffer)
{
	for (int i = 0; i < size; i++) {
		u32 y = feslite_naive_evaluation(n, Fq, Fl, buffer[i]);
		if (y != 0) {
			printf("not ok %d - %s gave false positive : F[%08x] = %08x\n", test, name, buffer[i], y);
			return false;
		}
	}
	printf("ok %d - %s returned %d valid solutions\n", test, name, size);
	return true;
}


/* check uniqueness */
bool check_uniqueness(int test, const char *name, int size, u32 *buffer)
{	
	for (int i = 0; i < size; i++) 
		for (int j = i + 1; j < size; j++) {
			if (buffer[i] == buffer[j]) {
				printf("not ok %d - %s returned buffer[%d] = buffer[%d]\n", test, name, i, j);
				return false;
			}
		}
	printf("ok %d - %s returned %d distinct solutions\n", test, name, size);
	return true;
}


int main()
{
	int n = 22;
	int k = 10;
	unsigned long random_seed = 1;

	int n_tests = 3 * feslite_num_kernels();
	printf("1..%d\n", n_tests);

	printf("# initalizing random system with seed=0x%lx\n", random_seed);
	mysrand(random_seed);

	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand() & ((1 << k) - 1);
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand() & ((1 << k) - 1);

	int big_count = 1 << 16;
	int big_size = 0;
	u32 big_buffer[big_count];
	
	printf("# using default kernel %s\n", feslite_kernel_name(feslite_default_kernel()));

	/* get all solutions */
	feslite_solve(n, 1, Fq, Fl, big_count, big_buffer, &big_size);
	if (big_size == big_count) {
		printf("Bail out! too many solutions --- fix test script\n");
		return EXIT_SUCCESS;
	}
	if (big_size < 0) {
		printf("not ok 1 - libfes_solve() failed\n");
		printf("Bail out! No input values\n");
		return EXIT_SUCCESS;
	}

	if (!check_correctness(1, "libfes_solve()", n, Fq, Fl, big_size, big_buffer)) {
		printf("Bail out! Broken library\n");
		return EXIT_SUCCESS;	
	}
	
	if (!check_uniqueness(2, "libfes_solve()", big_size, big_buffer)) {
		printf("Bail out! Broken library\n");
		return EXIT_SUCCESS;	
	}
	
	if (big_size > 100)
		printf("ok 3 - default kernel found %d solutions found (enough)\n", big_size);
	else {
		printf("not ok 3 - default kernel found ONLY %d solutions found (not enough)\n", big_size);
		printf("Bail out! borken test script ?\n");
		return EXIT_SUCCESS;
	}

	/* test other kernels */
	int test_idx = 1;
	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		if (!feslite_kernel_is_available(kernel))
			continue;
		const char *name = feslite_kernel_name(kernel);
		printf("# testing kernel %s\n", name);
	
		/* run kernel with small solution limit */
		int small_count = 10;
		u32 small_buffer[small_count];	
		int small_size = 0;
		feslite_kernel_solve(kernel, n, 1, Fq, Fl, small_count, small_buffer, &small_size);
			
		/* check solution number: it should have reached the cap*/
		if (small_size != small_count)
			printf("not ok %d - [%s] only %d solutions found, %d expected\n", test_idx++, name, small_size, small_count);
		else
			printf("ok %d - [%s] %d solutions found\n", test_idx++, name, small_count);

		check_correctness(3*kernel + 1, name, n, Fq, Fl, small_size, small_buffer);
		check_uniqueness(3*kernel + 2, name, small_size, small_buffer);

		/* check that solutions are a subset of big_buffer */
		bool failed = false;
		for (int i = 0; i < small_size; i++) {
			bool ok = false;
			for (int j = 0; j < big_size; j++)
				if (small_buffer[i] == big_buffer[j]) {
					ok = true;
					break;
				}
			if (!ok) {
				printf("not ok %d - %s found ``unknown'' solution F[%08x] = 0\n", 3*kernel + 3, name, small_buffer[i]);
				failed = true;
				break;
			}
		}
		if (!failed)
			printf("ok %d - %s found only known solutions\n", 3*kernel + 3, name);
	}
	return EXIT_SUCCESS;
}