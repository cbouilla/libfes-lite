#define _XOPEN_SOURCE

#include <stdint.h>
#include <stddef.h>
#include "generic/generic.h"



typedef int (*kernel_available_f)(void);
typedef size_t (*kernel_enumeration_f)(int, const uint32_t * const, uint32_t *, size_t, int);


struct enum_kernel_t {
	const char *name;
	const kernel_available_f available;
	const kernel_enumeration_f run;
};

struct eval_kernel_t {
	const char *name;
	const kernel_available_f available;
	const size_t batch_size;
	const kernel_enumeration_f run;
};


extern const struct enum_kernel_t ENUM_KERNEL[];

size_t kernel_num();
int kernel_available(const struct enum_kernel_t *kernel);
size_t kernel_num_available();
uint32_t naive_evaluation(int n, const uint32_t * const F, uint32_t x);
