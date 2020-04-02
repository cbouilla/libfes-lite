add_executable(list list.c)
target_link_libraries(list feslite)

add_executable(speed speed.c)
target_link_libraries(speed feslite m)

add_executable(speed_omp speed_omp.c)
target_link_libraries(speed_omp feslite m)
target_compile_options(speed_omp PRIVATE -fopenmp)
target_link_options(speed_omp PRIVATE -fopenmp)

add_executable(correct_use correct_use.c)
target_link_libraries(correct_use feslite)

# install(TARGETS makefb las las_descent freerel RUNTIME DESTINATION ${LIBSUFFIX}/sieve) 
