#include "feslite.h"

const struct enum_kernel_t ENUM_KERNEL[] = {
	{ "generic 1x32 (plain C)", NULL, generic_enum_1x32 },
    { "generic 2x16 (plain C)", NULL, generic_enum_2x16 },
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

