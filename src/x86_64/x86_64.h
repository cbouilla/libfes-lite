#include <emmintrin.h>

/** assembly code **/
//void feslite_x86_64_asm_enum_4x32(__m128i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint32_t idx);
// void feslite_x86_64_asm_enum_8x16(__m128i *F, uint64_t alpha_shift, void *buf, int64_t *num, uint32_t idx);

void feslite_x86_64_enum_4x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
