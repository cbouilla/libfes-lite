# here, we build the feslite library

add_library(feslite feslite.c naive_eval.c)
target_include_directories(feslite PUBLIC .)

target_sources(feslite INTERFACE feslite.h)

target_sources(feslite PRIVATE 
	feslite.c 
	naive_eval.c
	generic_minimal.c 
	generic_eval32.c 
	generic_1x32.c 
	generic_2x16.c 
	generic_2x32.c 
	generic_4x16.c
)

if(HAVE_SSE2)
	add_custom_command(
		COMMAND ${Python3_EXECUTABLE} sse2_codegen.py > ${CMAKE_CURRENT_SOURCE_DIR}/sse2_enum.s
		DEPENDS sse2_codegen.py
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/sse2_enum.s
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Generating code for sse2_enum.s"
	)

	target_sources(feslite PRIVATE 
		sse2_enum.s
		sse2_4x32.c  
		sse2_8x16.c
	)
endif()

if(HAVE_AVX2)
	add_custom_command(
		COMMAND ${Python3_EXECUTABLE} avx2_codegen.py > ${CMAKE_CURRENT_SOURCE_DIR}/avx2_enum.s
		DEPENDS avx2_codegen.py
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/avx2_enum.s
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Generating code for avx2_enum.s"
	)   

	target_sources(feslite PRIVATE 
		avx2_available.c
		avx2_enum.s
		avx2_8x32.c  
		avx2_16x16.c
	)
endif()


if(HAVE_AVX512BW)
	add_custom_command(
		COMMAND ${Python3_EXECUTABLE} avx512_codegen.py > ${CMAKE_CURRENT_SOURCE_DIR}/avx512_enum.s
		DEPENDS avx512_codegen.py
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/avx512_enum.s
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Generating code for avx512_enum.s"
	)   
	target_sources(feslite PRIVATE 
		avx512_enum.s
		avx512_16x32.c
		avx512_32x16.c
	)
endif()


install(TARGETS feslite DESTINATION lib)