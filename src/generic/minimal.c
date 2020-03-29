#include <stdio.h>
#include <assert.h>

#include "fes.h"
#include "ffs.h"
#include "monomials.h"

#define VERBOSE 0

void feslite_generic_minimal(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n <= 0 || n > 32 || m != 1) {
		*size = -1;
		return;
	}
	u64 init_start_time = Now();
	
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
	size[0] = 0;

	if (VERBOSE)
		printf("fes: initialisation = %" PRIu64 " cycles\n", Now() - init_start_time);

	u64 enumeration_start_time = Now();

	struct ffs_t ffs;
	ffs_reset(&ffs, n);
	ffs_step(&ffs);

	u32 i = 0;
	u32 upto = (1ull << n) - 1;
	while (1) {
		/* test */
		if (unlikely((Fl_[0] == 0))) {
			buffer[size[0]] = to_gray(i);
			size[0]++;
			if (size[0] == count)
				break;
		}
		
		/* step */
		int a = 1 + ffs.k1;
		int b = idxq(ffs.k1, ffs.k2);

		Fl_[a] ^= Fq_[b];
		Fl_[0] ^= Fl_[a];
		ffs_step(&ffs);

		if (i == upto)
			break;
		i++;
	}

	u64 enumeration_end_time = Now();
	if (VERBOSE)
		printf("fes: enumeration+check = %" PRIu64 " cycles\n", enumeration_end_time - enumeration_start_time);
}