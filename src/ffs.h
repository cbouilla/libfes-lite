#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* 
 * Constant-time algorithm to compute the position of the first and second bits
 * set in successive values of an (n+2)-bit counter initialized at (1 << (n+1)). 
 * Uses O(n^2) memory. 
 *
 * ffs_reset(&ffs, n)    sets the counter to "zero" (and initializes the data structure).
 * ffs_step(&ffs)        increments the counter     (and updates the data structure).
 *
 * At all times, k1 and k2 contains the position of the first and second bits 
 * set in the counter.
 *
 * Just after reset, k1 == n+1 and k2 == -1.
 *
 * with n = 0, the successive values of (k1, k2) are :
 *
 * i = 32 + 0		5, -1 
 * i = 32 + 1     	0,  5
 * i = 32 + 2     	1,  5
 * i = 32 + 3     	0,  1
 * i = 32 + 4     	2,  5
 * i = 32 + 5     	0,  2
 * i = 32 + 6     	1,  2
 * i = 32 + 7     	0,  1
 * i = 32 + 8     	3,  5
 * i = 32 + 9     	0,  3
 * i = 32 + 10     	1,  3
 * i = 32 + 11     	0,  1
 * i = 32 + 12     	2,  3
 * i = 32 + 13     	0,  2
 * i = 32 + 14     	1,  2
 * i = 32 + 15    	0,  1
 * i = 32 + 16    	4,  5
 *
 * This implementation not always the fastest possible solution 
 * (in particular if hardware instructions are available).
 * It is also not always faster than two successive "while" loops.
 * But it IS more elegant...
 */

struct ffs_t {
	int focus[34];
	int stack[33];
	int sp;
	int k1;
	int k2;
};


static void ffs_reset(struct ffs_t *context, int n)
{
	context->k1 = n+1;
	context->k2 = -1;
	context->sp = 1;
	context->stack[0] = n+1;
	for (int j = 0; j <= 32; j++)
		context->focus[j] = j;
}

static inline void ffs_step(struct ffs_t *context)
{
	/* update k1 using focus pointers */
	int j = context->focus[0];
	context->focus[0] = 0;
	context->focus[j] = context->focus[j + 1];
	context->focus[j + 1] = j + 1;
	context->k1 = j;

	/* update k2 using stack */
	context->sp -= j;
	context->k2 = context->stack[context->sp - 1];
	context->stack[context->sp] = j;
	context->sp += 1;
}

#if 0
#include <stdio.h>

void main()
{
	struct ffs_t ffs;
	ffs_reset(&ffs, 4);
	for (int i = 0; i <= 16; i++) {
		printf("%d\t%d\t%d\n", i, ffs.k1, ffs.k2);
		ffs_step(&ffs);
	}
}
#endif