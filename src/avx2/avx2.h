bool feslite_avx2_available();
void feslite_avx2_enum_8x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_avx2_enum_16x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
