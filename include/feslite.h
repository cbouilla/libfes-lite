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
int feslite_solve(int n, const uint32_t * const F, uint32_t * solutions, int max_solutions, bool verbose);


/* for experts, probing the state of the library is possible */
int feslite_num_kernels();
bool feslite_kernel_is_available(int i);
char const * feslite_kernel_name(int i);
int feslite_default_kernel();

/* solve using a specified kernel */
int feslite_kernel_solve(int i, int n, const uint32_t * const F, uint32_t * solutions, int max_solutions, bool verbose);