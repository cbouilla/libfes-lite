AUTOMAKE_OPTIONS = foreign

libfeslite_LTLIBRARIES = libfeslite.la 
libfeslitedir = $(libdir)
libfeslite_la_CPPFLAGS = -I$(top_srcdir)/src -I$(top_srcdir)/include
libfeslite_la_SOURCES = naive_eval.c \
	feslite.c\
	generic/minimal.c \
	generic/enum_1x32.c \
	generic/eval_32.c \
	#x86_64/asm_enum_4x32.s x86_64/enum_4x32.c \
	#x86_64/asm_enum_8x16.s x86_64/enum_8x16.c \
	#avx2/available.c \
	#avx2/asm_enum_8x32.s avx2/enum_8x32.c \
	#avx2/asm_enum_16x16.s avx2/enum_16x16.c
	
#generic/enum_2x16.c generic/enum_2x32.c generic/enum_4x16.c generic/eval_64.c

#include_HEADERS = fes.h feslite-config.h #generic/generic.h x86_64/x86_64.h avx2/avx2.h