#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"

/*
 * In this list, kernels are ordered by *increasing* preference
 * (fastest is last). The test suite assume kernel 0 to always work.
 */


const struct enum_kernel_t ENUM_KERNEL[] = {
	{"generic mini (32 bits, plain C)", 1, NULL, feslite_generic_minimal},
	{"generic 1x32 (32 bits, plain C)", 1, NULL, feslite_generic_enum_1x32},
	{"generic 2x16 (32 bits, plain C)", 2, NULL, feslite_generic_enum_2x16},
	{"generic 2x32 (64 bits, plain C)", 2, NULL, feslite_generic_enum_2x32},
	{"generic 4x16 (64 bits, plain C)", 4, NULL, feslite_generic_enum_4x16},
#ifdef __SSE2__
// 	/* all running intel CPUs should have SSE2 by now... */
 	{"x64-SSE2 4x32 (128 bits, C+asm)", 4, NULL, feslite_x86_64_enum_4x32},
 	{"x64-SSE2 8x16 (128 bits, C+asm)", 8, NULL, feslite_x86_64_enum_8x16},
#endif
#ifdef __AVX2__
 	{"x64-AVX2 8x32 (256 bits, C+asm)", 8, feslite_avx2_available, feslite_avx2_enum_8x32},
 	{"x64-AVX2 16x16 (256 bits, C+asm)", 16, feslite_avx2_available, feslite_avx2_enum_16x16},
#endif
	{NULL, 0, NULL, NULL}
};

int feslite_num_kernels()
{
	int n = 0;
	while (ENUM_KERNEL[n].name != NULL || ENUM_KERNEL[n].run != NULL)
		n++;
	return n;
}

bool feslite_kernel_is_available(int i)
{
	return (ENUM_KERNEL[i].available == NULL) || ENUM_KERNEL[i].available();
}

char const * feslite_kernel_name(int i)
{
	return ENUM_KERNEL[i].name;
}

void feslite_kernel_solve(int i, int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size)
{
	assert(feslite_kernel_is_available(i));
	ENUM_KERNEL[i].run(n, m, Fq, Fl, count, buffer, size);
}

int feslite_kernel_batch_size(int i)
{
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