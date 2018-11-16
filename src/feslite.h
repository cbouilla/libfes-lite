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

/* feslite_solve is the SINGLE external point of entry into the library.

arguments:
   - #variables
   - coefficients of the polynomial (see monomials.h)
   - pointer to solution buffer (preallocated)
   - size of the solution buffer
   - verbose flag

   return value:
   - number of solutions found

   The enumeration stops if it fills the solution buffer.
*/
size_t feslite_solve(size_t n, const uint32_t * const F_, uint32_t * solutions, size_t max_solutions, bool verbose);


/* returns the name of the kernel actually used */
char const * feslite_solver_name();





/* now, internal stuff */

typedef bool (*kernel_available_f)(void);
typedef size_t (*kernel_enumeration_f)(size_t, const uint32_t * const, uint32_t *, size_t, bool);


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


size_t feslite_kernel_num();
int feslite_kernel_available(const struct enum_kernel_t *kernel);
size_t feslite_kernel_num_available();
uint32_t feslite_naive_evaluation(size_t n, const uint32_t * const F, uint32_t x);

