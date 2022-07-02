#include <assert.h>
#include <sys/time.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <err.h>
#include <omp.h>

/* this program solves system of (arbitrarily many) quadratic polynomials in 
   <= MAX_VARIABLES variables. It first loads the system completely, then 
   converts the first 32 equations into the format libfes-lite expects. 
   Candidate solutions for the first 32 polynomials are then checked rather 
   naively against the remaining polynomials.

   If the first 32 polynomials have many solutions, then it would be faster to
   perform a random linear combination of all the polynomials prior to the 
   enumeration.

   If the first 32 polynomials have more than 65536 solutions, then some 
   partial solutions will be lost, which may result in full solutions being lost
   as well. A warning is printed in this case.
*/

#include "feslite.h"
#include "parser.h"

int n;              // #variables
int n_poly;         // #polynomials in the original system

/********************************* parser interface ***************************/

int idxq(int i, int j)
{
	return j * (j - 1) / 2 + i;
}

struct poly_t {
	int n_terms;
	int (*terms)[2];
};

struct poly_t * poly;
int capacity;    // size allocated for poly

void prepare_poly(struct poly_t *p)
{
	p->n_terms = 0;
	int size = idxq(0, n) + n + 1;
	p->terms = malloc(size * sizeof(*p->terms));
}

void setup(void *opaque, int _n, const char **vars)
{
	if (n > 64)
		errx(1, "This program only handles <= 64 variables.");
	n = _n;
	capacity = 64;
	poly = malloc(capacity * sizeof(*poly));
	prepare_poly(&poly[0]);
}

void store_monomial(void *opaque, int line, int column, int degree, const int *variables)
{
	if (degree > 2)
		errx(1, "monomial of degree %d on line %d col %d (max=2)\n", degree, line, column);

	// reduce squares
	if (degree == 2 && variables[0] == variables[1])
		degree = 1;

	struct poly_t *p = &poly[n_poly];
	int i = p->n_terms;
	int u = -1;
	int v = -1;
	if (degree == 1) {
		u = variables[0];
	} else if (degree == 2) {
		// order variables
		if (variables[0] < variables[1]) {
			u = variables[0];
			v = variables[1];
		} else {
			u = variables[1];
			v = variables[0];
		}
	}
	p->terms[i][0] = u;
	p->terms[i][1] = v;
	p->n_terms = i + 1;
}

void store_polynomial(void *opaque, int line)
{
	if (poly[n_poly].n_terms == 0)
		return;

	n_poly += 1;
	if (n_poly == capacity) {
		capacity = 1 + 2 * capacity;
		poly = realloc(poly, capacity * sizeof(*poly)); 
	}
	prepare_poly(&poly[n_poly]);
}

/***************************** parallel solving code **************************/

int h;              // number of specialized variables
int m;              // #lanes of the solver kernel
int n_poly_feslite; // #polynomials solved for using libfes-lite
u64 partial_solutions, total_solutions;
bool warned_lost;

/* initial system on <= 64 variables, truncated to 32 polynomials */
u32 Fq[2016];
u32 Fl[65];

#define MAX_BATCH_SIZE 64

struct bundle_t {
	int i;
	u32 prefixes[MAX_BATCH_SIZE];
	u32 Fl[];
};

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
	printf("solution found : (");
	for (int i = 0; i < n; i++) {
		printf("%01" PRId64, x & 1);
		x >>= 1;
		if (i != n-1)
			printf(", ");
	}
	printf(")\n");
}

// evaluate poly[i] on x
bool check_poly(int i, u64 x)
{
        bool y = false;
        struct poly_t *p = &poly[i];
        for (int j = 0; j < p->n_terms; j++) {
        	int u = p->terms[j][0];
		int v = p->terms[j][1];
		if (u == -1) {
			y ^= 1;
		} else if (v == -1) {
			y ^= (x >> u) & 1;
		} else {
			y ^= (x >> u) & (x >> v) & 1;
		}
        }
//        fprintf(stderr, "checking %" PRIx64 " against poly[%d], with %d terms --> %d\n", x, i, p->n_terms, y);
        return y;
}

void process_bundle(struct bundle_t *ready_bundle)
{
	/* solve ready bundle */
	int count = 65536;
	u32 buffer[count * m];
	int size[m];
	feslite_solve(n - h, m, Fq, ready_bundle->Fl, count, buffer, size);

	// check partial solutions against remaining equations, print full solutions
	for (int i = 0; i < m; i++) {
		if (size[i] == count)
			#pragma omp critical
			{
				if (!warned_lost)
					warnx("Possibly lost solutions");
				warned_lost = true;
			}
		#pragma omp atomic	
		partial_solutions += size[i];
		for (int j = 0; j < size[i]; j++) {
			u32 x = buffer[count*i + j];
			u64 p = ready_bundle->prefixes[i];
			u64 u = x ^ (p << (n - h));
			// check partial solution against other polynomials
			bool bad = false;
			for (int j = n_poly_feslite; j < n_poly; j++)
				bad |= check_poly(j, u);
			if (!bad) {
				#pragma omp critical
				print_solution(u);
				#pragma omp atomic
				total_solutions += 1;
			}
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
		fprintf(stderr, "\rcreated: %d\t Solved: %d\t In-flight: %d    ", created, solved, in_flight);
		fflush(stderr);
	}
}

/* push a system to the current bundle */
void push(const u32 * Fl, u32 prefix)
{
	created++;

	/* copy to current bundle */
	current_bundle->prefixes[current_bundle->i] = prefix;
	for (int j = 0; j < n - h + 1; j++)
		current_bundle->Fl[m *j + current_bundle->i] = Fl[j];
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

/******************************** go ******************************************/

int main(int argc, char **argv)
{
	parser(stdin, NULL, &setup, &store_monomial, &store_polynomial, NULL);
	fprintf(stderr, "Read %d polynomials in %d variables\n", n_poly, n);

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
	n_poly_feslite = n_poly;
	if (n_poly_feslite > 32)
		n_poly_feslite = 32;
	fprintf(stderr, "Specializing %d variables\n", h);
	fprintf(stderr, "Using kernel %s on %d variables, using %d lane(s)...\n", name, n - h, m);
	fprintf(stderr, "Enumerating %d polynomials, checking partial solutions against %d remaining polynomials\n", n_poly_feslite, n_poly - n_poly_feslite);

	/* create the truncated 32 bits version in Fl / Fq for enumeration */
	for (int i = 0; i < n_poly_feslite; i++) {
		struct poly_t *p = &poly[i];
		for (int j = 0; j < p->n_terms; j++) {
			int x = p->terms[j][0];
			int y = p->terms[j][1];
			if (x == -1) {
				Fl[0] += 1 << i;
			} else if (y == -1) {
				Fl[1 + x] += 1 << i;
			} else {
				Fq[idxq(x, y)] += 1 << i;
			}
		}
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
	fprintf(stderr, "\n");
	fprintf(stderr, "\t---> %" PRId64 " partial solution(s) checked\n", partial_solutions);
	fprintf(stderr, "\t---> %" PRId64 " solution(s) found\n", total_solutions);
	fprintf(stderr, "\t---> Finished in %.2f s\n", seconds);
	fprintf(stderr, "\t---> 2^%.2f candidate/s\n", rate);
	return EXIT_SUCCESS;
}