# libfes-lite v1.1 (a.k.a. "12-years edition", a.k.a. "Omicron BA.5 edition")

Lighter, leaner, meaner and faster.

libfes-lite is a library for solving systems of quadratic boolean equations by
exhaustive search. It runs in time exponential in the number of variables, but
the constant is very low.

Some care has been put into checking that libfes-lite produces corrects
results, and there is a somewhat extensive test suite. However, it comes
WITHOUT WARRANTY OF ANY KIND, and in particular, without the garantee that it
finds correct solutions in all cases.


## Build instructions

Building requires cmake. Building out-of-source is recommended

- `mkdir build`
- `cd build`
- `cmake ..`
- `make`
- (run the test suite) `make check`

## Demo and benchmarks

The `benchmark/` folder contains code that exercices the library. If you just
want to solve quadratic boolean systems, then use: 

- benchmark/demo.c        : full-blown program that solves a larger system of
                            quadratic equations using all available cores
Example:
```
# ./demo < examples/random_40_quad.in
```


If you want to understand how the whole thing works, and/or benchmark stuff, take a look at :

- benchmark/correct_use.c : demonstrates how to use the library
- benchmark/speed.c       : benchmarks all available kernels


## Input format

This code parses polynomial systems modulo 2 in the following format: 

+ Lines begining by a `#` are ignored.
+ Spaces, tabs, etc. are ignored.
+ The first non-comment line contains the names of all variables, separated 
  by commas.  This implicitly numbers them.  The first variable has number 0.
+ Each subsequent lines describe a polynomial.
+ A polynomial is a sum of monomials, separated by `+`
+ A monomial is either `0`, `1`, a single variable, or a product of several 
  variables separated by `*`.

(It follows that an empty line denote the zero polynomial).
