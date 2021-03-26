# libfes-lite v1.0 (a.k.a. "10-years edition", a.k.a. "COVID edition")

Lighter, leaner, meaner and faster.

libfes-lite is a library for solving systems of quadratic boolean equations by
exhaustive search. It runs in time exponential in the number of variables, but
the constant is very low.


## Build instructions

Building requires cmake. Building out-of-source is recommended

- `mkdir build`
- `cd build`
- `cmake ..`
- `make`
- (run the test suite) `make check`

## Demo and benchmarks

The `benchmark/` folder contains code that exercices the library.

- benchmark/correct_use.c : demonstrates how to use the library
- benchmark/demo.c        : full-blown program that solves a larger system of quadratic equations using all available cores
- benchmark/speed.c       : benchmarks all available kernels
