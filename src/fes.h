#ifndef FES_H
#define FES_H
#define _XOPEN_SOURCE

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include "feslite.h"
// #include "feslite-config.h"

#include "generic/generic.h"

#ifdef __SSE2__
extern struct solution_t * feslite_x86_64_asm_enum(const void * Fq, void * Fl, 
	                                      u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
void feslite_x86_64_enum_4x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_x86_64_enum_8x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif

#ifdef __AVX2__
extern struct solution_t * feslite_avx2_asm_enum(const void * Fq, void * Fl, 
						u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
bool feslite_avx2_available();
void feslite_avx2_enum_8x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_avx2_enum_16x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif

#ifdef __AVX512BW__
extern struct solution_t * feslite_avx512bw_asm_enum(const void * Fq, void * Fl, 
                  u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
void feslite_avx512bw_enum_16x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_avx512bw_enum_32x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif


#include "ffs.h"
#include "monomials.h"
#include "setup.h"

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
#endif