add_executable(list list.c)
target_link_libraries(list feslite)

add_executable(speed speed.c)
target_link_libraries(speed feslite m)

if (OPENMP_FOUND)
	add_executable(speed_omp speed_omp.c)
	target_link_libraries(speed_omp feslite m OpenMP::OpenMP_C)
	#target_compile_options(speed_omp PRIVATE ${OpenMP_C_FLAGS})

	add_executable(demo demo.c)
	target_link_libraries(demo feslite m OpenMP::OpenMP_C)
endif()

add_executable(correct_use correct_use.c)
target_link_libraries(correct_use feslite)

# install(TARGETS makefb las las_descent freerel RUNTIME DESTINATION ${LIBSUFFIX}/sieve) 
