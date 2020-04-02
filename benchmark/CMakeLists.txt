add_executable(list list.c)
add_executable(speed speed.c)
add_executable(correct_use correct_use.c)

target_link_libraries(list feslite)
target_link_libraries(speed feslite m)
target_link_libraries(correct_use feslite)

# install(TARGETS makefb las las_descent freerel RUNTIME DESTINATION ${LIBSUFFIX}/sieve) 
