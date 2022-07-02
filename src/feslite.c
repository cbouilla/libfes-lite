#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <math.h>

#include "fes.h"

/*
 * In this list, kernels are ordered by *increasing* preference
 * (fastest is last). The test suite assume kernel 0 to always work.
 */


const struct enum_kernel_t ENUM_KERNEL[] = {
/*   name, latency, min n, lanes, availability, code */
	{"generic_mini", 15.7, 1, 1, NULL, feslite_generic_minimal},
    {"generic_1x32", 3.14, 4, 1, NULL, feslite_generic_enum_1x32},
    {"generic_2x16", 2.87, 4, 2, NULL, feslite_generic_enum_2x16},
    {"generic_2x32", 3.22, 4, 2, NULL, feslite_generic_enum_2x32},
    {"generic_4x16", 5.57, 4, 4, NULL, feslite_generic_enum_4x16},
#ifdef __SSE2__
 	/* all running intel CPUs should have SSE2 by now... */
 	{"sse2_4x32", 2.18, 8, 4, feslite_sse2_available, feslite_sse2_enum_4x32},
 	{"sse2_8x16", 2.36, 8, 8, feslite_sse2_available, feslite_sse2_enum_8x16},
#endif
#ifdef __AVX2__
 	{"avx2_8x32", 2.13, 8, 8, feslite_avx2_available, feslite_avx2_enum_8x32},
 	{"avx2_16x16", 2.37, 8, 16, feslite_avx2_available, feslite_avx2_enum_16x16},
#endif
#ifdef __AVX512BW__
 	{"avx512bw_16x32", 3.02, 8, 16, feslite_avx512_available, feslite_avx512bw_enum_16x32},
 	{"avx512bw_32x16", 3.56, 8, 32, feslite_avx512_available, feslite_avx512bw_enum_32x16},
 	{"avx512bw_64x16", 5.10, 9, 64, feslite_avx512_available, feslite_avx512bw_enum_64x16},
#endif
};

int feslite_num_kernels()
{
	return sizeof(ENUM_KERNEL) / sizeof(struct enum_kernel_t);
}

int feslite_kernel_is_available(int i)
{
	if (i < 0 || i >= feslite_num_kernels())
		return FESLITE_EINVAL;
	return (ENUM_KERNEL[i].available == NULL) || ENUM_KERNEL[i].available();
}

char const * feslite_kernel_name(int i)
{
	if (i < 0 || i >= feslite_num_kernels())
		return NULL;
	return ENUM_KERNEL[i].name;
}

int feslite_kernel_find_by_name(const char *name)
{
	for (int i = 0; i < feslite_num_kernels(); i++)
		if (strcmp(name, ENUM_KERNEL[i].name) == 0)
			return i;
	return FESLITE_EINVAL;
}

int feslite_kernel_solve(int i, int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	if (i < 0 || i >= feslite_num_kernels())
		return FESLITE_EINVAL;
	if (!feslite_kernel_is_available(i))
		return FESLITE_ENOTAVAIL;
	return ENUM_KERNEL[i].run(n, m, Fq, Fl, count, buffer, size);
}

int feslite_kernel_batch_size(int i)
{
	if (i < 0 || i >= feslite_num_kernels())
		return FESLITE_EINVAL;
	return ENUM_KERNEL[i].batch_size;
}

int feslite_kernel_min_variables(int i)
{
	if (i < 0 || i >= feslite_num_kernels())
		return FESLITE_EINVAL;
	return ENUM_KERNEL[i].min_variables;
}

int feslite_default_kernel()
{
	for (int i = feslite_num_kernels() - 1; i >= 0 ; i--)
		if (feslite_kernel_is_available(i))
			return i;
	return FESLITE_EBUG;
}

int feslite_preferred_batch_size()
{
	return feslite_kernel_batch_size(feslite_default_kernel());
}

int feslite_choose_kernel(int n, int m)
{
	int candidate = -1;
	double latency = INFINITY;
	for (int i = 0; i < feslite_num_kernels(); i++) {
		if (ENUM_KERNEL[i].min_variables <= n && feslite_kernel_is_available(i)) {
			double n_iter = ceil(m / ENUM_KERNEL[i].batch_size);
			double candidate_lat = ENUM_KERNEL[i].latency * n_iter;
			if (candidate_lat < latency) {
				candidate = i;
				latency = candidate_lat;
			}
		}
	}
	if (candidate < 0)
		return FESLITE_EBUG;
	return candidate;	
}

int feslite_solve(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	/* verify input parameters */
	if (count <= 0 || n <= 0 || n > 32)
		return FESLITE_EINVAL;

	int kernel = feslite_choose_kernel(n, m);
	if (kernel < 0)
		return kernel;  /* error code */

	/* fast lane if the caller was smart */
	int batch_size = feslite_kernel_batch_size(kernel);
	if (m == batch_size)
		return feslite_kernel_solve(kernel, n, batch_size, Fq, Fl, count, buffer, size);

	/* The batch size does not match */
	int mm = m;
	while (mm >= batch_size) {
		u32 Fl_[(n + 1) * batch_size];
		for (int j = 0; j < n + 1; j++)
			for (int i = 0; i < batch_size; i++)
				Fl_[j * batch_size + i] = Fl[j * m + i];
		int rc = feslite_kernel_solve(kernel, n, batch_size, Fq, Fl_, count, buffer, size);
		if (rc != FESLITE_OK)
			return rc;
		buffer += batch_size * count;
		size += batch_size;
		Fl += batch_size;
		mm -= batch_size;
	}

	if (mm > 0) {
		/* One last pass with an incomplete batch. 
		   We must avoid the potential problem that unused lanes may overflow 
		   their solution buffer and stop the enumeration of "active" ones. 
		   To circumvent this, we **clone** one active lane. */
		u32 Fl_[(n + 1) * batch_size];
		u32 buffer_[count * batch_size];
		int size_[batch_size];
		for (int j = 0; j < n + 1; j++) {
			for (int i = 0; i < mm; i++)
				Fl_[j * batch_size + i] = Fl[j * m + i];
			for (int i = mm; i < batch_size; i++)
				Fl_[j * batch_size + i] = Fl[j * m];
		}
		int rc = feslite_kernel_solve(kernel, n, batch_size, Fq, Fl_, count, buffer_, size_);
		if (rc != FESLITE_OK)
			return rc;

		/* copy solutions to actual input */
		for (int i = 0; i < mm * count; i++)
			buffer[i] = buffer_[i];
		for (int i = 0; i < mm; i++) {
			assert(size_[i] <= count);
			size[i] = size_[i];
		}
	}
	return FESLITE_OK;
}