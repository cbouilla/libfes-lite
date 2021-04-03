// openmp program that solves a random system of up to 64 eqs in up to 64 vars.
#include <assert.h>
#include <sys/time.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <err.h>
#include <omp.h>

#include "feslite.h"

/* Try to solve a large system as fast as possible. */
int n = 45;

	
static inline int idxq(int i, int j)
{
	return j * (j - 1) / 2 + i;
}

u32 eval32(int n, const u32 * Fq, const u32 * Fl, int stride, u32 x)
{
	// first expand the values of the variables from `x`
	u32 v[32];
	for (int k = 0; k < n; k++) {
		v[k] = (x & 0x0001) ? 0xffffffff : 0x00000000;
		x >>= 1;
	}

	u32 y = Fl[0];

	for (int idx_0 = 0; idx_0 < n; idx_0++) {
		// computes the contribution of degree-1 terms
		u32 v_0 = v[idx_0];
		u32 l = Fl[stride * (1 + idx_0)];   // FIXME : get rid of this multiplication
		y ^= l & v_0;

		for (int idx_1 = 0; idx_1 < idx_0; idx_1++) {
			// computes the contribution of degree-2 terms
			u32 v_1 = v_0 & v[idx_1];
			u32 q = Fq[idxq(idx_1, idx_0)];
			y ^= q & v_1;
		}
	}
	return y;
}

u64 eval64(int n, const u64 * Q, const u64 * L, u64 x)
{
	u64 v[64];
	for (int k = 0; k < n; k++) {
		v[k] = (x & 1) ? 0xffffffffffffffffull : 0;
		x >>= 1ull;
	}
	assert(x == 0);
	u64 y = L[0];

	for (int i = 0; i < n; i++) {
		// computes the contribution of degree-1 terms
		y ^= L[1 + i] & v[i];
		for (int j = 0; j < i; j++)
			y ^= Q[idxq(j, i)] & v[i] & v[j];
	}
	return y;
}

u64 rand64()
{
	return ((u64) lrand48()) ^ (((u64) lrand48()) << 32ull);
}

u32 Fq[2016];

u64 Fq_start[2016];
u64 Fl_start[65];

#define MAX_BATCH_SIZE 64

struct bundle_t {
	int i;
	u32 prefixes[MAX_BATCH_SIZE];
	u32 Fl[];
};

int m;
struct bundle_t *current_bundle;
int in_flight, created, solved;

void fresh_bundle()
{
	current_bundle = malloc(sizeof(struct bundle_t) + 33*m*sizeof(u32));
	if (current_bundle == NULL)
		err(1, "impossible to allocate new bundle");
	current_bundle->i = 0;

	#pragma omp atomic
	in_flight++;
}

void process_bundle(struct bundle_t *ready_bundle)
{
	/* solve ready bundle */
	int count = 256;
	u32 buffer[count * m];
	int size[m];
	feslite_solve(32, m, Fq, ready_bundle->Fl, count, buffer, size);

	// check against remaining equations, print
	for (int i = 0; i < m; i++)
		for (int j = 0; j < size[i]; j++) {
			u32 x = buffer[count*i + j];
			u32 y = eval32(32, Fq, ready_bundle->Fl + i, m, x);
			assert(y == 0);
			u64 p = ready_bundle->prefixes[i];
			u64 u = x ^ (p << 32);
			u64 v = eval64(n, Fq_start, Fl_start, u);
			if (v == 0)
				printf("\nfound %016" PRIx64 "\n", u);
		}

	/* free ready bundle */
	free(ready_bundle);

	#pragma omp atomic
	solved += m;

	#pragma omp atomic
	in_flight--;

	#pragma omp critical
	{
		printf("\rcreated: %d\t Solved: %d\t In-flight: %d    ", created, solved, in_flight);
		fflush(stdout);
	}
}

/* push a system to the current bundle */
void push(const u32 * Fl, u32 prefix)
{
	created++;

	/* copy to current bundle */
	current_bundle->prefixes[current_bundle->i] = prefix;
	for (int j = 0; j < 33; j++)
		current_bundle->Fl[m *j + current_bundle->i] = Fl[j];
	current_bundle->i += 1;

	/* bundle full? */
	if (current_bundle->i == m) {
		/* prepare new bundle */
		struct bundle_t *ready_bundle = current_bundle;
		fresh_bundle();
		#pragma omp task
		process_bundle(ready_bundle);
	}
}

void specialize(int n, const u32 * Fl, u32 prefix)
{
	if (n == 32) {
		push(Fl, prefix);
		return;
	}

	/* specialize last variable to zero : do nothing! */
	specialize(n-1, Fl, prefix << 1);

	/* specialize last variable to one */
	u32 Fl_[n];
	for (int i = 0; i < n-1; i++)
		Fl_[i + 1] = Fl[i + 1] ^ Fq[idxq(i, n-1)];
	Fl_[0] = Fl[0] ^ Fl[n];

	specialize(n-1, Fl_, (prefix << 1) ^ 1);
}



int main(int argc, char **argv)
{
	if (argc > 1)
		n = atoi(argv[1]);
	if (n < 32) {
		fprintf(stderr, "n < 32 not fully supported yet\n");
		exit(1);
	}

	m = feslite_preferred_batch_size();	
	printf("n = %d\n", n);
	int kernel = feslite_default_kernel();
	const char *name = feslite_kernel_name(kernel);
	printf("Using kernel %s, %d lane(s)...\n", name, m);
	
	srand48(1337);
	
	/* initalize a random system */	
	int N = idxq(0, n);
	for (int i = 0; i < N; i++)
		Fq_start[i] = rand64();
	for (int i = 0; i < n+1; i++)
		Fl_start[i] = rand64();
	u64 x = rand64() & ((1ull << n) - 1);   /* designated solution */
	Fl_start[0] ^= eval64(n, Fq_start, Fl_start, x);
	assert(0 == eval64(n, Fq_start, Fl_start, x));
	printf("Planted: %016" PRIx64 "\n", x);


	/* create the truncated 32 bits version */
	u32 Fl[65];
	for (int i = 0; i < N; i++)
		Fq[i] = Fq_start[i] & 0xffffffff;
	for (int i = 0; i < n+1; i++)
		Fl[i] = Fl_start[i] & 0xffffffff;
	
	fresh_bundle();

	double start_wt = omp_get_wtime();
	
	#pragma omp parallel
	#pragma omp single
	{
		specialize(n, Fl, 0);
		if (current_bundle->i > 0) {
			#pragma omp task
			process_bundle(current_bundle);
		}
	}
	
	double stop_wt = omp_get_wtime();

	double seconds = stop_wt - start_wt;
	double rate = n - log2(seconds);
	printf("\t---> %.2f s\n", seconds);
	printf("\t---> 2^%.2f candidate/s\n", rate);

	return EXIT_SUCCESS;
}