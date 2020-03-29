
#include <assert.h>
#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

int main()
{
	unsigned long random_seed = 1338;

	printf("1..32\n");

	/*************** setup *****************/
	printf("# initalizing random system with seed=0x%lx\n", random_seed);

	mysrand(random_seed);
	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand();
	Fl[0] = 0;
	u32 x = myrand(); /* designated solution */
	Fl[0] = feslite_naive_evaluation(32, Fq, Fl, 1, x);
	printf("# F[%08x] = 0\n", x);

	u32 inbuffer[32];
	u32 outbuffer[32];

	/******************** go *******************/
	for (int i = 1; i <= 32; i++) {
		printf("# testing with %d inputs\n", i);
		for (int j = 0; j < 32; j++)
			inbuffer[j] = myrand();
		int k = (myrand() & 0xff) % i;
		// assert(0 <= k);
		// assert(k < i);
		inbuffer[k] = x;

		int size = 0;

		// printf("[in test script] Fq        = %p\n", Fq);
		// printf("[in test script] Fl        = %p\n", Fl);
		// printf("[in test script] inbuffer  = %p\n", inbuffer);
		// printf("[in test script] outbuffer = %p\n", outbuffer);
		// printf("[in test script] size      = %p\n", &size)	;

		feslite_generic_eval_32(32, Fq, Fl, 1, i, inbuffer, 32, outbuffer, &size);

		if (size == 1)
			printf("ok %d - expected solution found\n", i);
		else
			printf("not ok %d - expected solution NOT found\n", i);
	}
	return EXIT_SUCCESS;
}