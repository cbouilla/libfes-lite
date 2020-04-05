#include <stdio.h>
#include <err.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "feslite.h"

int ntest = 0;

void test_kernel_run(int kernel)
{
	if (!feslite_kernel_is_available(kernel))
		return;

	const char *name = feslite_kernel_name(kernel);
	int m = feslite_kernel_batch_size(kernel);

	u32 Fl[33 * m];
	u32 Fq[529];
	int count = 256;
	u32 buffer[count * m];
	int size[m];
	for (int i = 0; i < 529; i++)
		Fq[i] = 0;
	for (int i = 0; i < 33 * m; i++)
		Fl[i] = 0;
	
	/* should run OK */
	int rc = feslite_kernel_solve(kernel, 16, m, Fq, Fl, count, buffer, size);
	if (rc == FESLITE_OK)
		printf("ok %d - kernel [%s] succeeded\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] failed\n", ++ntest, name);
		
	/* bad n */
	rc = feslite_kernel_solve(kernel, 45, m, Fq, Fl, count, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with n=45\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with n=45\n", ++ntest, name);

	/* bad n */
	rc = feslite_kernel_solve(kernel, 0, m, Fq, Fl, count, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with n=0\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with n=0\n", ++ntest, name);

	/* bad n */
	rc = feslite_kernel_solve(kernel, -30, m, Fq, Fl, count, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with n=-30\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with n=-30\n", ++ntest, name);

	/* bad m */
	rc = feslite_kernel_solve(kernel, 16, m+1, Fq, Fl, count, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with bogus m\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with bogus m\n", ++ntest, name);

	/* bad count */
	rc = feslite_kernel_solve(kernel, 16, m, Fq, Fl, 0, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with count=0\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with count=0\n", ++ntest, name);

	/* bad count */
	rc = feslite_kernel_solve(kernel, 16, m, Fq, Fl, -1, buffer, size);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - kernel [%s] with count=-1\n", ++ntest, name);
	else
		printf("not ok %d - kernel [%s] with count=-1\n", ++ntest, name);
}

void test_kernel_run_unavail(int kernel)
{
	if (feslite_kernel_is_available(kernel))
		return;

	int rc = feslite_kernel_solve(kernel, 32, 4, NULL, NULL, 0, NULL, NULL);
	if (rc == FESLITE_ENOTAVAIL)
		printf("ok %d - feslite_kernel_solve w/ unavailable kernel\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_solve w/ unavailable kernel\n", ++ntest);
}


void test_kernel_names()
{
	/* inexistent kernel */
	int rc = feslite_kernel_find_by_name("foobar");
	if (rc == FESLITE_EINVAL)
		printf("ok %d - feslite_kernel_find_by_name() w/ bad name\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_find_by_name() w/ bad name\n", ++ntest);

	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		const char *name = feslite_kernel_name(kernel);
		int rc = feslite_kernel_find_by_name(name);
		if (rc != FESLITE_EINVAL)
			printf("ok %d - feslite_kernel_find_by_name() w/ good name\n", ++ntest);
		else
			printf("not ok %d - feslite_kernel_find_by_name() w/ good name\n", ++ntest);
		if (rc == kernel)
			printf("ok %d - feslite_kernel_find_by_name() w/ good name / good value\n", ++ntest);
		else
			printf("not ok %d - feslite_kernel_find_by_name() w/ good name / good value\n", ++ntest);
	}
}


void test_kernel_available()
{
	/* inexistent kernel */
	int rc = feslite_kernel_is_available(1337);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - feslite_kernel_available w/ bad kernel\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_available w/ bad kernel\n", ++ntest);

	rc = feslite_kernel_is_available(-1);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - feslite_kernel_available w/ bad kernel\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_available w/ bad kernel\n", ++ntest);

	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		int rc = feslite_kernel_is_available(kernel);		
		if (rc == 0 || rc == 1)
			printf("ok %d - feslite_kernel_available w/ good kernel\n", ++ntest);
		else
			printf("not ok %d - feslite_kernel_available w/ good kernel\n", ++ntest);
	}
}



void test_kernel_batch_size()
{
	/* inexistent kernel */
	int rc = feslite_kernel_batch_size(1337);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - feslite_kernel_batch_size w/ bad kernel\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_batch_size w/ bad kernel\n", ++ntest);

	rc = feslite_kernel_batch_size(-1);
	if (rc == FESLITE_EINVAL)
		printf("ok %d - feslite_kernel_batch_size w/ bad kernel\n", ++ntest);
	else
		printf("not ok %d - feslite_kernel_batch_size w/ bad kernel\n", ++ntest);

	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		int rc = feslite_kernel_batch_size(kernel);		
		if (rc >= 0)
			printf("ok %d - feslite_kernel_batch_size w/ good kernel\n", ++ntest);
		else
			printf("not ok %d - feslite_kernel_batch_size w/ good kernel\n", ++ntest);
	}
}

int main(int argc, char **argv)
{
	test_kernel_names();
	test_kernel_available();
	test_kernel_batch_size();

	for (int kernel = 0; kernel < feslite_num_kernels(); kernel++) {
		test_kernel_run(kernel);
		test_kernel_run_unavail(kernel);
	}
	printf("1..%d\n", ntest);
	return EXIT_SUCCESS;
}