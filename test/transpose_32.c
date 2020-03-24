#include <stdio.h>
#include <err.h>
#include <stdlib.h>

#include "fes.h"
#include "rand.h"

void test_pattern_80000000()
{
	u32 A[32];
	u32 B[32];
	for (int i = 0; i < 32; i++)
		A[i] = 0;
	A[31] = 0xffffffff;

	feslite_transpose_32(A, B);

	for (int i = 0; i < 32; i++)
		if (B[i] != 0x80000000) {
			printf("not ok 1 - got B[%d] = %08x\n", i, B[i]);
			return;
		}
	printf("ok 1 - pattern 0x80000000\n");
}

void test_pattern_00000001()
{
	u32 A[32];
	u32 B[32];
	for (int i = 0; i < 32; i++)
		A[i] = 0;
	A[0] = 0xffffffff;

	feslite_transpose_32(A, B);

	for (int i = 0; i < 32; i++)
		if (B[i] != 0x00000001) {
			printf("not ok 2 - got B[%d] = %08x\n", i, B[i]);
			return;
		}
	printf("ok 2 - pattern 0x00000001\n");
}

void test_involutive()
{
	u32 A[32];
	u32 B[32];
	u32 C[32];
	for (int i = 0; i < 32; i++)
		A[i] = myrand();

	feslite_transpose_32(A, B);
	feslite_transpose_32(B, C);

	for (int i = 0; i < 32; i++)
		if (A[i] != C[i]) {
			printf("not ok 3 - A[%d] != C[%d]\n", i, i);
			return;
		}
	printf("ok 3 - involutive\n");
}


int main()
{
	mysrand(1337);
	printf("1..3\n");
	test_pattern_80000000();
	test_pattern_00000001();
	test_involutive();
	return EXIT_SUCCESS;
}