#include <immintrin.h>

/** assembly code **/
void feslite_avx2_asm_enum_8x32(__m256i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint64_t idx);
void feslite_avx2_asm_enum_16x16(__m256i *F, uint64_t alpha_shift, void *buf, uint64_t *num, uint64_t idx);

bool feslite_avx2_available();

size_t feslite_avx2_enum_8x32(size_t n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    bool verbose);

size_t feslite_avx2_enum_16x16(size_t n, const uint32_t * const F_,
			    uint32_t * solutions, size_t max_solutions,
			    bool verbose);

