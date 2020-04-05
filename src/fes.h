#ifndef FES_H
#define FES_H
#define _XOPEN_SOURCE

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#include "feslite.h"

#define unlikely(x)     __builtin_expect(!!(x), 0)

static inline int idxq(int i, int j)
{
  return j * (j - 1) / 2 + i;
}

static inline uint32_t to_gray(uint32_t i)
{
  return (i ^ (i >> 1));
}

typedef bool (*kernel_available_f)(void);
typedef int (*kernel_enumeration_f)(int, int, const u32 *, const uint32_t *, int, u32 *, int *);

/** plain-C enumeration kernels **/

/* 32-bits registers only */
int feslite_generic_minimal(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_generic_enum_1x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_generic_enum_2x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);

/* 64 bits registers */
int feslite_generic_enum_2x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_generic_enum_4x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);

/* helper functions */
void feslite_transpose_32(const u32 * M, u32 * T);

/* evaluate a quadratic function on a single point */
u32 feslite_naive_evaluation(int n, const u32 * Fq, const u32 * Fl, int stride, u32 x);

/* batch-evaluate a quadratic function on several input vectors.
   inputs are checked against equations [16:32]
   inbuf must be of size 32 no matter what. */
void feslite_generic_eval_32(int n, const u32 * Fq, const u32 * Fl, int stride, 
              int incount, const u32 *inbuf, 
              int outcount, u32 *outbuf, int *size);



/** architecture-specific enumeration kernels **/
bool feslite_sse2_available();
bool feslite_avx2_available();
bool feslite_avx512_available();

#ifdef __SSE2__
extern struct solution_t * feslite_sse2_asm_enum(const void * Fq, void * Fl, 
	                                      u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
int feslite_sse2_enum_4x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_sse2_enum_8x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif

#ifdef __AVX2__
extern struct solution_t * feslite_avx2_asm_enum(const void * Fq, void * Fl, 
						u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
int feslite_avx2_enum_8x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_avx2_enum_16x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif

#ifdef __AVX512BW__
extern struct solution_t * feslite_avx512bw_asm_enum(const void * Fq, void * Fl, 
                  u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
extern struct solution_t * feslite_avx512x2bw_asm_enum(const void * Fq, void * Fl, 
                  u64 alpha, u64 beta, u64 gamma, struct solution_t *local_buffer);
int feslite_avx512bw_enum_16x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_avx512bw_enum_32x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
int feslite_avx512bw_enum_64x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
#endif

/* misc stuff */

#include "ffs.h"
#include "setup.h"

struct enum_kernel_t {
   const char *name;
   double latency;
   int minimum_variables;
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

#endif