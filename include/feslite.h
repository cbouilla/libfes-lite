#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

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

