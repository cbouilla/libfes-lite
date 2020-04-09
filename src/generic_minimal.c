#include <assert.h>
#include <stdio.h>
#include "fes.h"

int feslite_generic_minimal(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n <= 0 || n > 32 || m != 1)
		return FESLITE_EINVAL;

	size[0] = 0;
	u32 Fq_[561];
	u32 Fl_[34];
	
	setup32(n, 1, Fq, Fl, Fq_, Fl_);

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

		// printf("step %d : k1 = %d, k2 = %d\n", i, ffs.k1, ffs.k2);

		Fl_[a] ^= Fq_[b];
		Fl_[0] ^= Fl_[a];
		ffs_step(&ffs);

		if (i == upto)
			break;
		i++;
	}
	return FESLITE_OK;
}