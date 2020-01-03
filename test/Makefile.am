AM_TESTS_ENVIRONMENT = env AM_TAP_AWK='$(AWK)'
LOG_DRIVER = $(SHELL) $(top_srcdir)/build-aux/tap-driver.sh

AM_CPPFLAGS = -I$(top_srcdir)/src -I$(top_srcdir)/include
AM_LDFLAGS = -lm
LDADD = $(top_builddir)/src/libfeslite.la rand.o

TESTS = many_solutions designated_solution consistency
EXTRA_DIST = $(TESTS)

check_PROGRAMS = designated_solution many_solutions consistency
