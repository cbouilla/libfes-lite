#ifndef _PARSER_H_
#define _PARSER_H_

/*
 * This code parses polynomial systems modulo 2 in the following format: 
 *
 * + Lines begining by a # are ignored.
 *
 * + Spaces, tabs, etc. are ignored.
 *
 * + The first non-comment line contains the names of all variables, separated 
 *   by commas.  This implicitly numbers them. The first variable has number 0.
 *
 * + Each subsequent lines describe a polynomial.
 *
 * + A polynomial is a sum of monomials, separated by +
 *
 * + A monomial is either 0, 1, a single variable, or a product of several 
 *   variables separated by *.
 *
 * (It follows that an empty line denote the zero polynomial)
 *
 *                         ---------------------------
 *
 * The parser interface relies on callbacks (this is inspired by the design of
 * expat).
 *
 * + Once the variable names have been read, the "variables callback" is
 *   invoked; along with the number and names of the variables.
 *
 * + Once a monomial has been read, the "monomial callback is invoked, along 
 *   with an array describing the variables in the monomial (they are given by
 *   number).
 *   
 * + Once a polynomial has been read, the "polynomial callback}"is invoked. 
 * 
 * + Once parsing is finished, a "finalization callback" is invoked. 
 *
 * + Each callback is given a pointer to an opaque object provided by the caller.
 *
 */

#include <stdio.h>

typedef void (*variables_callback_t)(void * opaque, int n, const char ** var_names);
typedef void (*monomial_callback_t)(void * opaque, int line, int column, int degree, 
				const int * variables);
typedef void (*polynomial_callback_t)(void * opaque, int line);
typedef void (*finalization_callback_t)(void * opaque);

void parser(FILE * input, void * opaque, variables_callback_t v, monomial_callback_t m, 
                polynomial_callback_t p, finalization_callback_t f);

#endif