# hardcoded list of kernels to test
set(KERNELS 
	generic_mini
	generic_1x32
	generic_2x16
	generic_2x32
	generic_4x16
	sse2_4x32
	sse2_8x16
	avx2_8x32
	avx2_16x16
	avx512bw_16x32
	avx512bw_32x16
    avx512bw_64x16
)

# declare a test that: 
#   - is built with rand.c
#   - is linked with feslite
#   - fails if it crashes or prints "not ok" (TAP protocol)
macro(fes_test _name _source)
    add_executable(${_name} EXCLUDE_FROM_ALL ${_source} rand.c)
    if (TARGET ${_name})
        target_link_libraries(${_name} feslite)
        add_test(NAME ${_name} COMMAND ${_name})
        set_tests_properties(${_name} PROPERTIES FAIL_REGULAR_EXPRESSION "not ok")
        set (FES_TESTS ${FES_TESTS} ${_name})
    endif()
endmacro()


# declare a test juste like before, but in addition that runs on all kernels: 
macro(fes_kernel_test _name _source)
    add_executable(${_name} EXCLUDE_FROM_ALL ${_source} rand.c)
    target_link_libraries(${_name} feslite)
    if (TARGET ${_name})
        set (FES_TESTS ${FES_TESTS} ${_name})
        foreach(kernel ${KERNELS})
        	add_test(NAME ${_name}-${kernel} COMMAND ${_name} ${kernel})
        	set_tests_properties(${_name}-${kernel} PROPERTIES FAIL_REGULAR_EXPRESSION "not ok")
            set_tests_properties(${_name}-${kernel} PROPERTIES SKIP_RETURN_CODE 2)
        endforeach()
    endif()
endmacro()

# standalone tests
fes_test(naive_eval naive_eval.c)
fes_test(transpose_32 transpose_32.c)
fes_test(batch_eval_32 batch_eval_32.c)
fes_test(interface interface.c)
fes_test(loop_invariants loop_invariants.c)
fes_test(loop_invariants2 loop_invariants2.c)
fes_test(loop_invariants2_64 loop_invariants2_64.c)
fes_test(loop_invariants3 loop_invariants3.c)

# kernel tests
fes_kernel_test(zero zero.c)
fes_kernel_test(designated_solution designated_solution.c)
fes_kernel_test(consistency consistency.c)
fes_kernel_test(many_solutions many_solutions.c)
fes_kernel_test(special_solutions special_solutions.c)

##############################################################################

set(SYSTEMS 
    linear_zero
    linear_ones
    linear_alternating
    random_32_quad
    structured_32
    structured_34
    structured_38
    structured_40
)

foreach(system ${SYSTEMS})
    add_test (NAME demo-${system}
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test_solver_tool.py ../benchmark/demo ${PROJECT_SOURCE_DIR}/benchmark/examples/${system}.in
    )
endforeach()

# create "make check"
add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} DEPENDS ${FES_TESTS})