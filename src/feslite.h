#ifndef FESLITE_H
#define FESLITE_H
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

#define FESLITE_OK         0
#define FESLITE_EINVAL    -1  /* invalid arguments */
#define FESLITE_ENOTAVAIL -2  /* requested kernel not available on this machine */
#define FESLITE_EBUG      -3  /* internal bug ; email maintainer */

/* 
 * There is ONE entry point to the library:
 * - feslite_solve : solve related systems.
 *
 * Arguments:
 *  - n      : [IN]  number of variables
 *  - m      : [IN]  number related systems
 *  - Fq     : [IN]  coefficients of the quadratic terms (see monomials.h)
 *  - Fl     : [IN]  coefficients of the other terms     (see monomials.h)
 *  - count  : [IN]  size of the solution buffer
 *  - buffer : [OUT] solution buffer (size m*count)
 *  - size   : [OUT] the number of solutions of each system, size m
 *
 * n must be less than or equal to 32.
 * Fq has size n * (n + 1) / 2. This is upper-bounded by 496 in all cases.
 * Fl has size (n + 1) * m.
 *
 * The number of solutions of the i-th system is written in size[i]
 * The solutions of the i-th system can be found in buffer at index i*m.
 *
 * The enumeration stops if it fills one of the solution buffers.
 * (this implies that if a solution buffer is full, then solutions may have been
 * missed, both in the same or in other lanes).
 *
 * return value: FESLITE_OK or an error code.
 */
int feslite_solve(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int * size);

/*
 * For tuning : return the optimal number of related subsystems to give to feslite_solve()
 */
int feslite_preferred_batch_size();

/*
 * For experts, probing the state of the library is possible.
 */
int feslite_num_kernels();
int feslite_kernel_is_available(int i);
char const * feslite_kernel_name(int i);
int feslite_kernel_batch_size(int i);
int feslite_kernel_min_variables(int i);

/*
 * The library has a preferred kernel.
 * When in doubt, use the default :-).  But the problem must have enough 
 * variables.  There is also a simple mechanism to choose the best kernel while
 * respecting constraints on the number of variables.
 */
int feslite_default_kernel();
int feslite_choose_kernel(int n, int m);

/* convenience function; returns FESLITE_EINVAL when given a bogus name) */
int feslite_kernel_find_by_name(const char *name);

/* Solve a single system using the i-th kernel. 
 * The CORRECT batch size (m) must be used.
 * n must be larger than the value given by feslite_kernel_min_variables(). */
int feslite_kernel_solve(int i, int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int * size);
#endif