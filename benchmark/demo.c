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
#include "parser.h"

	
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

/* initial system on <= 64 variables */
u64 Fq_start[2016];
u64 Fl_start[65];

/********************************* parallel solving code **************************/

// 32-bit truncated version
u32 Fq[2016];
#define MAX_BATCH_SIZE 64

struct bundle_t {
	int i;
	u32 prefixes[MAX_BATCH_SIZE];
	u32 Fl[];
};

int n;  // #variables
int h;  // number of specialized variables
int m;  // #lanes of the solver kernel
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

void print_solution(u64 x)
{
        printf("\nsolution found : (");
        for (int i = 0; i < n; i++) {
                printf("%01" PRId64, x & 1);
                x >>= 1;
                if (i != n-1)
                        printf(", ");
        }
        printf(")\n");
}

void process_bundle(struct bundle_t *ready_bundle)
{
	/* solve ready bundle */
	int count = 256;
	u32 buffer[count * m];
	int size[m];
	feslite_solve(n - h, m, Fq, ready_bundle->Fl, count, buffer, size);

	// check against remaining equations, print
	for (int i = 0; i < m; i++) {
		if (size[i] == count)
			warn("Possibly lost solution\n");
		for (int j = 0; j < size[i]; j++) {
			u32 x = buffer[count*i + j];
			u32 y = eval32(n - h, Fq, ready_bundle->Fl + i, m, x);
			// printf("partial %08x\n", x);
			assert(y == 0);
			u64 p = ready_bundle->prefixes[i];
			u64 u = x ^ (p << (n - h));
			u64 v = eval64(n, Fq_start, Fl_start, u);
			if (v == 0)
				print_solution(u);
		}
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
	for (int j = 0; j < n - h + 1; j++) {
		current_bundle->Fl[m *j + current_bundle->i] = Fl[j];
		// printf("Fl[%2d] = %08x\n", j, Fl[j]);
	}
	current_bundle->i += 1;

	/* bundle full? */
	if (current_bundle->i == m) {
		/* prepare new bundle */
		struct bundle_t *ready_bundle = current_bundle;
		fresh_bundle();

		/* solve the complete bundle asynchronously */
		#pragma omp task
		process_bundle(ready_bundle);
	}
}

void specialize(int fixed, const u32 * Fl, u32 prefix)
{
	if (fixed == h) {
		push(Fl, prefix);
		return;
	}

	/* specialize last variable to zero : do nothing! */
	specialize(fixed + 1, Fl, prefix << 1);

	/* specialize last variable to one */
	int _n = n - fixed;
	u32 Fl_[_n];
	for (int i = 0; i < _n - 1; i++)
		Fl_[i + 1] = Fl[i + 1] ^ Fq[idxq(i, _n - 1)];
	Fl_[0] = Fl[0] ^ Fl[_n];

	specialize(fixed + 1, Fl_, (prefix << 1) ^ 1);
}

/************************************* random systems **************************************/

void usage()
{
	printf("./demo N                  generate and solve a random quadratic system on N var");
	printf("./demo < equations.txt    parse and solve the quadratic system given in the file");
}


u64 rand64()
{
	return ((u64) lrand48()) ^ (((u64) lrand48()) << 32ull);
}

void setup_random()
{
	printf("Generating random system of %d variables / %d quadratic polynomials\n", n, n);
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
}

/**** parser interface *****/

int n_poly;      // #polynomials
bool nonempty;   // current polynomial empty?

void store_variables(void *opaque, int _n, const char **_vars)
{
        n = _n;
}

void store_monomial(void *opaque, int line, int column, int degree, const int *variables)
{
        if (n_poly >= 64)
                return;
        if (degree > 2)
                errx(1, "monomial of degree %d on line %d col %d (max=2)\n", degree, line, column);
        u64 mask = (1ull << n_poly);
        if (degree == 0)
        	Fl_start[0] ^= mask;
        if (degree == 1)
        	Fl_start[1 + variables[0]] ^= mask;
        if (degree == 2) {
        	int u = variables[0];
        	int v = variables[1];
        	if (u == v)
        		errx(1, "squares not allowed (line %d, col %d)\n", line, column);
        	if (u < v)
        		Fq_start[idxq(u, v)] ^= mask;
        	else
        		Fq_start[idxq(v, u)] ^= mask;
        }
        nonempty = true;
}

void store_polynomial(void *opaque, int line)
{
        if (nonempty == false)
                return;
        if (n_poly >= 64)
                warnx("Ignoring polynomial on line %d\n", line);
        n_poly += 1;
        nonempty = false;
}

void finalize(void *opaque)
{
        printf("Read %d polynomials in %d variables\n", n_poly, n);
}

/*********************************************** go ******************************************/

int main(int argc, char **argv)
{
	if (argc > 1) {
		n = atoi(argv[1]);
		setup_random();
	} else {
		parser(stdin, NULL, &store_variables, &store_monomial, &store_polynomial, &finalize);
	}

	int kernel = feslite_default_kernel();
	int min_n = feslite_kernel_min_variables(kernel);
	if (n < min_n)
		errx(1, "Default kernel requires at least %d variables\n", min_n);
	m = feslite_kernel_batch_size(kernel);
	const char *name = feslite_kernel_name(kernel);


	/* determine #variables to specialize */
	if (n > 32)
		h = n - 32;
	while ((1 << h) < m)
		h += 1;
	printf("Specializing %d variables\n", h);
	printf("Using kernel %s on %d variables, using %d lane(s)...\n", name, n - h, m);
	
	/* create the truncated 32 bits version in Fl / Fq */
	int N = idxq(0, n);
	u32 Fl[65];
	for (int i = 0; i < N; i++) {
		Fq[i] = Fq_start[i] & 0xffffffff;
		// printf("Fq[%3d] = %08x\n", i, Fq[i]);
	}
	for (int i = 0; i < n+1; i++) {
		Fl[i] = Fl_start[i] & 0xffffffff;
		// printf("Fl[%2d] = %08x\n", i, Fl[i]);
	}
	
	/* solve */
	double start_wt = omp_get_wtime();
	fresh_bundle();
	#pragma omp parallel
	#pragma omp single
	{
		specialize(0, Fl, 0);
		if (current_bundle->i > 0) {
			#pragma omp task
			process_bundle(current_bundle);
		}
	}
	double stop_wt = omp_get_wtime();

	double seconds = stop_wt - start_wt;
	double rate = n - log2(seconds);
	printf("\n");
	printf("\t---> Finished in %.2f s\n", seconds);
	printf("\t---> 2^%.2f candidate/s\n", rate);
	return EXIT_SUCCESS;
}