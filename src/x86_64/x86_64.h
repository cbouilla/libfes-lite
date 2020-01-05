#include <emmintrin.h>

/** assembly code **/
void feslite_x86_64_asm_enum_4x32(__m128i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint32_t idx);
void feslite_x86_64_asm_enum_8x16(__m128i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint32_t idx);

int feslite_x86_64_enum_4x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, int max_solutions,
			    bool verbose);

int feslite_x86_64_enum_8x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, int max_solutions,
			    bool verbose);