# here, we build the feslite library

add_library(feslite feslite.c naive_eval.c)
target_include_directories(feslite PUBLIC .)

target_sources(feslite INTERFACE feslite.h)

target_sources(feslite PRIVATE feslite.c naive_eval.c)


target_sources(feslite PRIVATE 
	generic/minimal.c 
	generic/eval_32.c 
	generic/enum_1x32.c 
	generic/enum_2x16.c 
	generic/enum_2x32.c 
	generic/enum_4x16.c
)

enable_language(ASM)
target_sources(feslite PRIVATE 
	x86_64/asm_enum_4x32.s
	x86_64/enum_4x32.c  
	x86_64/asm_enum_8x16.s
	x86_64/enum_8x16.c
)


install(TARGETS feslite DESTINATION lib)