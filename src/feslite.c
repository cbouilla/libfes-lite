#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <assert.h>

#include "fes.h"

const struct enum_kernel_t ENUM_KERNEL[] = {
#ifdef __AVX2__
	{ "x64-AVX2 16x16 (256 bits, C+asm)", feslite_avx2_available, feslite_avx2_enum_16x16 },
	{ "x64-AVX2 8x32 (256 bits, C+asm)", feslite_avx2_available, feslite_avx2_enum_8x32 },
#endif

#ifdef __SSE2__
	/* all running intel CPUs should have SSE2 by now... */
	{ "x64-SSE2 8x16 (128 bits, C+asm)", NULL, feslite_x86_64_enum_8x16 },
	{ "x64-SSE2 4x32 (128 bits, C+asm)", NULL, feslite_x86_64_enum_4x32 },
#endif
#if 0
        // these take too long to compile
	{ "generic 4x16 (64 bits, plain C)", NULL, generic_enum_4x16 },
	{ "generic 2x16 (32 bits, plain C)", NULL, generic_enum_2x16 },
	{ "generic 2x32 (64 bits, plain C)", NULL, generic_enum_2x32 },
#endif
	{ "generic 1x32 (32 bits, plain C)", NULL, feslite_generic_enum_1x32 },
	{ NULL, NULL, NULL}
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

int feslite_kernel_solve(int i, int n, const uint32_t * const F, uint32_t * solutions, int max_solutions, bool verbose)
{
	assert(feslite_kernel_is_available(i));
	return ENUM_KERNEL[i].run(n, F, solutions, max_solutions, verbose);
}

int feslite_default_kernel()
{
	for (int i = 0; i < feslite_num_kernels(); i++)
		if (feslite_kernel_is_available(i))
			return i;
	return -1;
}

int feslite_solve(int n, const uint32_t * const F, uint32_t * solutions, int max_solutions, bool verbose)
{
	return feslite_kernel_solve(feslite_default_kernel(), n, F, solutions, max_solutions, verbose);
}