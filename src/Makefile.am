AUTOMAKE_OPTIONS = foreign

libfeslite_LTLIBRARIES = libfeslite.la 
libfeslitedir = $(libdir)
libfeslite_la_SOURCES = naive_eval.c feslite.c\
	generic/enum_1x32.c generic/enum_2x16.c generic/eval_32.c \
	generic/enum_2x32.c generic/enum_4x16.c generic/eval_64.c

libfeslite_la_SOURCES += x86_64/asm_enum_4x32.s x86_64/enum_4x32.c
	
include_HEADERS = feslite.h generic/generic.h

include_HEADERS += x86_64/x86_64.h