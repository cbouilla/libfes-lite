#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* 
 * Constant-time algorithm to compute the position of the first and second bits
 * set in successive values of an n-bit counter initialized at zero. Uses O(n log n) memory. 
 *
 * ffs_reset()  sets the counter to zero (and initializes the data structure).
 * ffs_step()   increments the counter   (and updates the data structure).
 *
 * At all times, k1 and k2 contains the position of the first and second bits set in the counter.
 *
 * When the counter is zero, k1 == k2 == -1. When the counter has only one bit set, k2 == -1.
 *
 * This is not always the fastest possible solution (in particular if hardware instructions are available).
 * It is also not always faster than two successive "while" loops.
 * But it IS more elegant...
 */

struct ffs_t {
	int focus[33];
	int stack[32];
	int sp;
	int k1;
	int k2;
};


static void ffs_reset(struct ffs_t *context)
{
	context->k1 = -1;
	context->k2 = -1;
	context->sp = 1;
	context->stack[0] = -1;
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