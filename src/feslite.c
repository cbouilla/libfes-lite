#include "feslite.h"

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


size_t feslite_kernel_num()
{
	size_t n = 0;
	while (1) {
		if (ENUM_KERNEL[n].name == NULL && ENUM_KERNEL[n].run == NULL)
			break;
		n++;
	}
	return n;
}

int feslite_kernel_available(const struct enum_kernel_t *kernel)
{
	return (kernel->available == NULL) || kernel->available();
}

size_t feslite_kernel_num_available()
{
	size_t n = 0;
	while (1) {
		if (ENUM_KERNEL[n].name == NULL && ENUM_KERNEL[n].run == NULL)
			break;
		if (feslite_kernel_available(&ENUM_KERNEL[n]))
			n++;
	}
	return n;
}

size_t feslite_solve(size_t n, const uint32_t * const F, uint32_t * solutions, size_t max_solutions, bool verbose)
{
	for (size_t i = 0; i < feslite_kernel_num(); i++)
		if (feslite_kernel_available(&ENUM_KERNEL[i]))
			return ENUM_KERNEL[i].run(n, F, solutions, max_solutions, verbose);
	return 0;
}

char const * feslite_solver_name()
{
	for (size_t i = 0; i < feslite_kernel_num(); i++)
		if (feslite_kernel_available(&ENUM_KERNEL[i]))
			return ENUM_KERNEL[i].name;
	return NULL;
}