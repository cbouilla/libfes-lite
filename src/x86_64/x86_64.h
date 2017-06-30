#include <emmintrin.h>

/** assembly code **/
extern void x86_64_asm_enum_4x32(__m128i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint32_t idx);
extern void x86_64_asm_enum_8x16(__m128i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint32_t idx);

size_t x86_64_enum_4x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

size_t x86_64_enum_8x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

