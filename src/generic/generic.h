#include "feslite.h"

/** plain-C enumeration kernels **/
/* 32-bits registers only */
void feslite_generic_minimal(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_generic_enum_1x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_generic_enum_2x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);

/* 64 bits registers */
void feslite_generic_enum_2x32(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);
void feslite_generic_enum_4x16(int n, int m, const u32 * Fq, const u32 * Fl, int count, u32 * buffer, int *size);

/* helper functions */
void feslite_transpose_32(const u32 * M, u32 * T);

/* batch-evaluate a quadratic function on several input vectors.
   inputs are checked against equations [16:32]
   inbuf must be of size 32 no matter what. */
void feslite_generic_eval_32(int n, const u32 * Fq, const u32 * Fl, int stride, 
			     int incount, const u32 *inbuf, 
			     int outcount, u32 *outbuf, int *size);


#if 0
int generic_enum_2x16(int n, const uint32_t * const F,
			    uint32_t * solutions, int max_solutions,
			    int verbose);

/** generic 64-bit code **/

int generic_enum_2x32(int n, const uint32_t * const F,
			    uint32_t * solutions, int max_solutions,
			    int verbose);
int generic_enum_4x16(int n, const uint32_t * const F,
			    uint32_t * solutions, int max_solutions,
			    int verbose);
#endif