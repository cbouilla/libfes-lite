#include <emmintrin.h>

/** assembly code **/
extern void x86_64_asm_enum_4x32(__m128i *F, int alpha, void *buf, uint64_t *num, uint32_t idx);
//extern void func_deg_2_T_3_el_0(__m128i *F, uint64_t *F_sp, void *buf, uint64_t *num, uint64_t idx);

size_t x86_64_enum_4x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

size_t x86_64_enum_8x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

