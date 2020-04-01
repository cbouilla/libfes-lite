# Test for SSE-2 and cache the result

if(sse2_test_cached)    
   
    set (HAVE_SSE2 ${HAVE_SSE2_cached})

else()

    message(STATUS "Testing whether sse-2 code can be used")
    try_run(sse2_runs sse2_compiles
                ${PROJECT_BINARY_DIR}/config
                ${PROJECT_SOURCE_DIR}/config/sse2.c)
    if(sse2_compiles)
        if (sse2_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether sse-2 code can be used -- No")
            set (HAVE_SSE2 OFF)
        else()
            message(STATUS "Testing whether sse-2 code can be used -- Yes")
            set (HAVE_SSE2 ON)
        endif()
    else()
        try_run(sse2_runs sse2_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/sse2.c
            COMPILE_DEFINITIONS -msse2)
        if(sse2_compiles)
            if (sse2_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether sse-2 code can be used -- No")
    	    set (HAVE_SSE2 OFF)
            else()
                message("${sse2_runs}")
                message(STATUS "Testing whether sse-2 code can be used -- Yes, with -msse2")
                set (HAVE_SSE2 ON)
            endif()
        else()
            message(STATUS "Testing whether sse-2 code can be used -- No (cannot compile)")
            set (HAVE_SSE2 OFF)
        endif()
    endif()

    # cache the result
    set (HAVE_SSE2_cached ${HAVE_SSE2} CACHE BOOL "SSE2 available")
    set (sse2_test_cached ON CACHE BOOL "The test for SSE2 has been run")
endif()

# update flags according to the result of the (potentially cached) test
if(HAVE_SSE2)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse2")
endif()
