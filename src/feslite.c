#include "feslite.h"

const struct enum_kernel_t ENUM_KERNEL[] = {
#if 0
	{ "generic 1x32 (32 bits, plain C)", NULL, generic_enum_1x32 },
	{ "generic 2x16 (32 bits, plain C)", NULL, generic_enum_2x16 },
	{ "generic 2x32 (64 bits, plain C)", NULL, generic_enum_2x32 },
	{ "generic 4x16 (64 bits, plain C)", NULL, generic_enum_4x16 },
#endif
#ifdef __SSE2__
	{ "x64-SSE2 4x32 (128 bits, C+asm)", NULL, x86_64_enum_4x32 },
	{ "x64-SSE2 8x16 (128 bits, C+asm)", NULL, x86_64_enum_8x16 },
#endif
#ifdef __AVX2__
	{ "x64-AVX2 8x32 (256 bits, C+asm)", NULL, avx2_enum_8x32 },
	{ "x64-AVX2 16x16 (256 bits, C+asm)", NULL, avx2_enum_16x16 },
#endif

	{ NULL, NULL, NULL}
};


size_t kernel_num()
{
	size_t n = 0;
	while (1) {
		if (ENUM_KERNEL[n].name == NULL && ENUM_KERNEL[n].run == NULL)
			break;
		n++;
	}
	return n;
}

int kernel_available(const struct enum_kernel_t *kernel)
{
	return (kernel->available == NULL) || kernel->available();
}

size_t kernel_num_available()
{
	size_t n = 0;
	while (1) {
		if (ENUM_KERNEL[n].name == NULL && ENUM_KERNEL[n].run == NULL)
			break;
		if (kernel_available(&ENUM_KERNEL[n]))
			n++;
	}
	return n;
}

