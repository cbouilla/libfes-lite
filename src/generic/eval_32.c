#include <assert.h>
#include <stdio.h>

#include "monomials.h"
#include "generic.h"

static const u32 M1_HI = 0xffff0000;
static const u32 M1_LO = 0x0000ffff;
static const u32 M2_HI = 0xff00ff00;
static const u32 M2_LO = 0x00ff00ff;
static const u32 M3_HI = 0xf0f0f0f0;
static const u32 M3_LO = 0x0f0f0f0f;
static const u32 M4_HI = 0xcccccccc;
static const u32 M4_LO = 0x33333333;
static const u32 M5_HI = 0xaaaaaaaa;
static const u32 M5_LO = 0x55555555;

/* this code was written by Antoine Joux for his book 
  "algorithmic cryptanalysis" (cf. http://www.joux.biz). It
  was slighlty modified by C. Bouillaguet. Just like the original, it is licensed 
  under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License. */
void feslite_transpose_32(const u32 * M, u32 * T)
{
	/* to unroll manually */
	for (int l = 0; l < 16; l++) {
		T[l] = (M[l] & M1_LO) | ((M[l + 16] & M1_LO) << 16);
		T[l + 16] = ((M[l] & M1_HI) >> 16) | (M[l + 16] & M1_HI);
	}

	for (int l0 = 0; l0 < 32; l0 += 16) {
		for (int l = l0; l < l0 + 8; l++) {
			u32 val1 = (T[l] & M2_LO) | ((T[l + 8] & M2_LO) << 8);
			u32 val2 = ((T[l] & M2_HI) >> 8) | (T[l + 8] & M2_HI);
			T[l] = val1;
			T[l + 8] = val2;
		}
	}

	for (int l0 = 0; l0 < 32; l0 += 8) {
		for (int l = l0; l < l0 + 4; l++) {
			u32 val1 = (T[l] & M3_LO) | ((T[l + 4] & M3_LO) << 4);
			u32 val2 = ((T[l] & M3_HI) >> 4) | (T[l + 4] & M3_HI);
			T[l] = val1;
			T[l + 4] = val2;
		}
	}

	for (int l0 = 0; l0 < 32; l0 += 4) {
		for (int l = l0; l < l0 + 2; l++) {
			u32 val1 = (T[l] & M4_LO) | ((T[l + 2] & M4_LO) << 2);
			u32 val2 = ((T[l] & M4_HI) >> 2) | (T[l + 2] & M4_HI);
			T[l] = val1;
			T[l + 2] = val2;
		}
	}

	for (int l = 0; l < 32; l += 2) {
		u32 val1 = (T[l] & M5_LO) | ((T[l + 1] & M5_LO) << 1);
		u32 val2 = ((T[l] & M5_HI) >> 1) | (T[l + 1] & M5_HI);
		T[l] = val1;
		T[l + 1] = val2;
	}
}

/* warning: inbuf must be of size 32, regardless of the actual number of inputs.
            inputs are checked against equations [16:32] */
void feslite_generic_eval_32(int n, const u32 * Fq, const u32 * Fl, int stride, 
			     int incount, const u32 *inbuf, 
			     int outcount, u32 *outbuf, int *size)
{
	/* FIXME : consider getting rid of this. This function is internal !*/
	assert(incount <= 32);
	*size = 0;
	
	// printf("[DEBUG] eval32 : n=%d, %d input candidates, %d output slots\n", n, incount, outcount);
	// for (int i = 0; i < incount; i++)
	// 	printf("[DEBUG] - %08x\n", inbuf[i]);

	if (incount == 0 || outcount == 0)
		return;

	u32 bitslice[32];
	feslite_transpose_32(inbuf, bitslice);

	u32 valid = 0xffffffff; // for each of the inputs, does it still pass?
	for (int i = 16; i < 32; i++) {
		/* linear terms */
		u32 y = (Fl[0] & (1ul << i)) ? 0xffffffff : 0;	
		for (int j = 0; j < n; j++)
			y ^= bitslice[j] & ((Fl[stride * (1 + j)] & (1 << i)) ? 0xffffffff : 0);

		/* quadratic terms */
		for (int j = 1; j < n; j++)
			for (int k = 0; k < j; k++)
				y ^= bitslice[j] & bitslice[k] & ((Fq[idxq(k, j)] & (1 << i)) ? 0xffffffff : 0);
	
		valid &= ~y;
		/* early abort? */
		// if (!valid) {
		// 	*size = 0;
		// 	return;
		// }
	}

	for (int i = 0; i < incount; i++)
		if (valid & (1ul << i)) {
			outbuf[*size] = inbuf[i];
			(*size)++;
			if ((*size) == outcount)
				break;
		}
}