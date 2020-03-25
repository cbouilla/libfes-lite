#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */


int main()
{
	unsigned long random_seed = 1337;
	mysrand(random_seed);
	
	printf("1..2\n");

	/*************** setup *****************/
	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand();
	Fl[0] = 0;
	
	u32 x = myrand(); /* designated solution, 32 variables */
	Fl[0] = feslite_naive_evaluation(32, Fq, Fl, x);
	u32 y = feslite_naive_evaluation(32, Fq, Fl, x);

	if (y == 0)
		printf("ok 1 - feslite_naive_evaluation finds designated solution (n=32)\n");
	else
		printf("not ok 1 - feslite_naive_evaluation did NOT find designated solution (n=32)\n");
	
	x = myrand() & ((1 << 27) - 1); /* designated solution, 27 variables */
	Fl[0] = 0;
	Fl[0] = feslite_naive_evaluation(27, Fq, Fl, x);
	y = feslite_naive_evaluation(27, Fq, Fl, x);

	if (y == 0)
		printf("ok 2 - feslite_naive_evaluation finds designated solution (n=27)\n");
	else
		printf("not ok 2 - feslite_naive_evaluation did NOT find designated solution (n=27). Got %08x\n", y);

	return EXIT_SUCCESS;
}