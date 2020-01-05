#include <immintrin.h>

/** assembly code **/
void feslite_avx2_asm_enum_8x32(__m256i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint64_t idx);
void feslite_avx2_asm_enum_16x16(__m256i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint64_t idx);

bool feslite_avx2_available();

int feslite_avx2_enum_8x32(int n, const uint32_t * const F_,
			    uint32_t * solutions, int max_solutions,
			    bool verbose);

int feslite_avx2_enum_16x16(int n, const uint32_t * const F_,
			    uint32_t * solutions, int max_solutions,
			    bool verbose);

