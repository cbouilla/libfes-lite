#define _XOPEN_SOURCE

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>


#include "feslite-config.h"
#include "generic/generic.h"

#ifdef __SSE2__
#include "x86_64/x86_64.h"
#endif

#ifdef __AVX2__
#include "avx2/avx2.h"
#endif

#include "feslite.h"
#include "cycleclock.h"

typedef uint64_t u64;

typedef bool (*kernel_available_f)(void);
typedef void (*kernel_enumeration_f)(int, int, const u32 *, const uint32_t *, int, u32 *, int *);

struct enum_kernel_t {
   const char *name;
   int batch_size;
   kernel_available_f available;
   kernel_enumeration_f run;
};

struct eval_kernel_t {
   const char *name;
   kernel_available_f available;
   size_t batch_size;
   kernel_enumeration_f run;
};

extern const struct enum_kernel_t ENUM_KERNEL[];

u32 feslite_naive_evaluation(int n, const u32 * Fq, const u32 * Fl, int stride, u32 x);