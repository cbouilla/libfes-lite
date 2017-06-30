AC_INIT([libfes-lite],[0.1],[charles.bouillaguet@univ-lille1.fr])
AC_PREREQ([2.69])
AC_CANONICAL_HOST
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE([foreign check-news subdir-objects])
AC_CONFIG_HEADERS([src/config.h])
AM_MAINTAINER_MODE

# Checks for programs.
#AC_PROG_CC
AC_PROG_CC_C99
AC_PROG_MAKE_SET
AC_PROG_AWK     # for TAP
AC_PROG_INSTALL
AM_PROG_AS
AM_PROG_AR
AC_PROG_LIBTOOL
LT_INIT([disable-static])

AC_REQUIRE_AUX_FILE([tap-driver.sh])


# Checks for header files.
AC_HEADER_STDC

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T

AX_CHECK_X86_FEATURES
AX_CACHE_SIZE

CFLAGS="$CFLAGS -Wall -Wextra"

AC_SUBST(CFLAGS)
AC_SUBST(LDFLAGS)

AC_CONFIG_FILES([Makefile src/Makefile test/Makefile benchmark/Makefile])
AC_OUTPUT
