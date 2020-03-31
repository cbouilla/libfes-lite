AM_TESTS_ENVIRONMENT = env AM_TAP_AWK='$(AWK)'
LOG_DRIVER = $(SHELL) $(top_srcdir)/build-aux/tap-driver.sh

AM_CPPFLAGS = -I$(top_srcdir)/src -I$(top_srcdir)/include
AM_LDFLAGS = -lm
LDADD = $(top_builddir)/src/libfeslite.la rand.o

TESTS = naive_eval \
	batch_eval_32 \
	transpose_32 \
	many_solutions \
	designated_solution \
	consistency \
	zero \
	special_solutions

EXTRA_DIST = $(TESTS)

check_PROGRAMS = naive_eval designated_solution many_solutions consistency special_solutions batch_eval_32 transpose_32 zero
