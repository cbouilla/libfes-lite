# declare a test that: 
#   - is built with rand.c
#   - is linked with feslite
#   - fails if it crashes or prints "not ok" (TAP protocol)

macro (fes_test _name _source)
    add_executable(${_name} EXCLUDE_FROM_ALL ${_source} rand.c)
    if (TARGET ${_name})
        target_link_libraries(${_name} feslite)
        add_test(NAME ${_name} COMMAND ${_name})
        set_tests_properties(${_name} PROPERTIES FAIL_REGULAR_EXPRESSION "not ok")
        set (FES_TESTS ${FES_TESTS} ${_name})
    endif()
endmacro()

fes_test(naive_eval naive_eval.c)
fes_test(transpose_32 transpose_32.c)
fes_test(batch_eval_32 batch_eval_32.c)
fes_test(zero zero.c)
fes_test(designated_solution designated_solution.c)
fes_test(consistency consistency.c)
fes_test(many_solutions many_solutions.c)
fes_test(special_solutions special_solutions.c)

add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND} DEPENDS ${FES_TESTS})