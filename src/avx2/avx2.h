#include <immintrin.h>

/** assembly code **/
extern void avx2_asm_enum_8x32(__m256i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint64_t idx);
extern void avx2_asm_enum_16x16(__m256i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint64_t idx);

size_t avx2_enum_8x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

size_t avx2_enum_16x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    int verbose);

