#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>

#include "fes.h"

/*
 * In this list, kernels are ordered by *increasing* preference
 * (fastest is last). The test suite assume kernel 0 to always work.
 */


const struct enum_kernel_t ENUM_KERNEL[] = {
	{"generic_mini", 1, NULL, feslite_generic_minimal},
	{"generic_1x32", 1, NULL, feslite_generic_enum_1x32},
	{"generic_2x16", 2, NULL, feslite_generic_enum_2x16},
	{"generic_2x32", 2, NULL, feslite_generic_enum_2x32},
	{"generic_4x16", 4, NULL, feslite_generic_enum_4x16},
#ifdef __SSE2__
// 	/* all running intel CPUs should have SSE2 by now... */
 	{"sse2_4x32", 4, feslite_sse2_available, feslite_sse2_enum_4x32},
 	{"sse2_8x16", 8, feslite_sse2_available, feslite_sse2_enum_8x16},
#endif
#ifdef __AVX2__
 	{"avx2_8x32", 8, feslite_avx2_available, feslite_avx2_enum_8x32},
 	{"avx2_16x16", 16, feslite_avx2_available, feslite_avx2_enum_16x16},
#endif
#ifdef __AVX512BW__
 	{"avx512bw_16x32", 16, feslite_avx512_available, feslite_avx512bw_enum_16x32},
 	{"avx512bw_32x16", 32, feslite_avx512_available, feslite_avx512bw_enum_32x16},
 	{"avx512bw_64x16", 64, feslite_avx512_available, feslite_avx512bw_enum_64x16},
#endif
	{NULL, 0, NULL, NULL}
};

int feslite_num_kernels()
{
	int n = 0;
	while (ENUM_KERNEL[n].name != NULL)
		n++;
	return n;
}

bool feslite_kernel_is_available(int i)
{
	// TODO : check i...
	return (ENUM_KERNEL[i].available == NULL) || ENUM_KERNEL[i].available();
}

char const * feslite_kernel_name(int i)
{
	// TODO : check i...
	return ENUM_KERNEL[i].name;
}

int feslite_kernel_find_by_name(const char *name)
{
	int i = 0;
	while (ENUM_KERNEL[i].name != NULL) {
		if (strcmp(name, ENUM_KERNEL[i].name) == 0)
			return i;
		i++;
	}
	return -1;
}

void feslite_kernel_solve(int i, int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	// TODO : check i...
	assert(feslite_kernel_is_available(i));
	ENUM_KERNEL[i].run(n, m, Fq, Fl, count, buffer, size);
}

int feslite_kernel_batch_size(int i)
{
	// TODO : check i...
	assert(feslite_kernel_is_available(i));
	return ENUM_KERNEL[i].batch_size;
}

int feslite_default_kernel()
{
	for (int i = feslite_num_kernels() - 1; i >= 0 ; i--)
		if (feslite_kernel_is_available(i))
			return i;
	assert(false);
}

int feslite_preferred_batch_size()
{
	return feslite_kernel_batch_size(feslite_default_kernel());
}

void feslite_solve(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	// ici introduire un mécanisme qui gère le fait que m n'a pas la bonne taille
	feslite_kernel_solve(feslite_default_kernel(), n, m, Fq, Fl, count, buffer, size);
}