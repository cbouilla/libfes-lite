#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

/** create a random system with a known solution,
    then test that the kernels correctly find this solution. */

void test_n32()
{
	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand();
	
	u32 x = myrand(); /* designated solution, 32 variables */
	Fl[0] = 0;
	Fl[0] = feslite_naive_evaluation(32, Fq, Fl, 1, x);
	u32 y = feslite_naive_evaluation(32, Fq, Fl, 1, x);

	if (y == 0)
		printf("ok 1 - feslite_naive_evaluation finds designated solution (n=32)\n");
	else
		printf("not ok 1 - feslite_naive_evaluation did NOT find designated solution (n=32)\n");
}


void test_n27()
{
	u32 Fq[496];
	u32 Fl[33];
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 33; i++)
		Fl[i] = myrand();
	
	u32 x = myrand() & ((1 << 27) - 1); /* designated solution, 27 variables */
	Fl[0] = 0;
	Fl[0] = feslite_naive_evaluation(27, Fq, Fl, 1, x);
	u32 y = feslite_naive_evaluation(27, Fq, Fl, 1, x);

	if (y == 0)
		printf("ok 2 - feslite_naive_evaluation finds designated solution (n=27)\n");
	else
		printf("not ok 2 - feslite_naive_evaluation did NOT find designated solution (n=27). Got %08x\n", y);
}


void test_stride()
{
	u32 Fq[496]; 
	u32 Fl[264]; // 8 * 33
	for (int i = 0; i < 496; i++)
		Fq[i] = myrand();
	for (int i = 0; i < 264; i++)
		Fl[i] = myrand();

	for (int i = 0; i < 8; i++) {
		u32 x = myrand(); /* designated solution, 32 variables */
		Fl[i] = 0;
		Fl[i] = feslite_naive_evaluation(32, Fq, &Fl[i], 8, x);
		u32 y = feslite_naive_evaluation(32, Fq, &Fl[i], 8, x);
		if (y != 0) {
			printf("not ok 3 - feslite_naive_evaluation did NOT find designated solution (n=32, multi-lane)\n");
			return;
		}
	}
	printf("ok 3 - feslite_naive_evaluation finds designated solution (n=32, multi-lane)\n");
}


int main()
{
	mysrand(1337);	
	printf("1..3\n");
	test_n32();
	test_n27();
	test_stride();
	return EXIT_SUCCESS;
}