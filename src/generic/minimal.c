#include <stdio.h>
#include <assert.h>

#include "fes.h"
#include "ffs.h"
#include "monomials.h"

#define VERBOSE 0

void feslite_generic_minimal(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n <= 0 || n > 32 || m <= 0) {
		*size = -1;
		return;
	}
	/* restricted sets of inputs */
	assert(m == 1);
	assert(n < 31);

	uint64_t init_start_time = Now();

	u32 Fq_[NQUAD];
	u32 Fl_[NLIN];
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		Fq_[i] = Fq[i];
	Fq_[idxq(0, n)] = 0;
	for (int i = 1; i < n; i++)
		Fq_[idxq(i, n)] = Fq[idxq(i-1, i)];
	Fq_[idxq(n, n)] = 0;
	for (int i = 0; i < n + 1; i++)
		Fl_[i] = Fl[i];
	*size = 0;

	if (VERBOSE)
		printf("fes: initialisation = %" PRIu64 " cycles\n", Now() - init_start_time);

	u64 enumeration_start_time = Now();

	struct ffs_t ffs;
	ffs_reset(&ffs, n);
	ffs_step(&ffs);

	for (u32 i = 0; i < (1ul << n); i++) {
		/* test */
		if (unlikely((Fl_[0] == 0))) {
			buffer[*size] = to_gray(i);
			(*size)++;
			if (*size == count)
				break;
		}
		
		/* step */
		int a = 1 + ffs.k1;
		int b = idxq(ffs.k1, ffs.k2);

		// printf("i = %08x. Stepping with k1=%2d, k2=%2d, a=%3d, b=%3d\n", i, ffs.k1, ffs.k2, a, b);

		Fl_[a] ^= Fq_[b];
		Fl_[0] ^= Fl_[a];
		ffs_step(&ffs);
	}

	u64 enumeration_end_time = Now();
	if (VERBOSE)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n", enumeration_end_time - enumeration_start_time);
}