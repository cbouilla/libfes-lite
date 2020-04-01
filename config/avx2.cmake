# avx2

if(avx2_test_cached)    
   
    set (HAVE_AVX2 ${HAVE_AVX2_cached})

else()

    message(STATUS "Testing whether avx2 code can be used")
    try_run(avx2_runs avx2_compiles
        ${PROJECT_BINARY_DIR}/config
        ${PROJECT_SOURCE_DIR}/config/avx2.c)
    if(avx2_compiles)
        if (avx2_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether avx2 code can be used -- No")
            set (HAVE_AVX2 OFF)
        else()
            message(STATUS "Testing whether avx2 code can be used -- Yes")
            set (HAVE_AVX2 ON)
        endif()
    else()
        try_run(avx2_runs avx2_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/avx2.c
            COMPILE_DEFINITIONS -mavx2)
        if(avx2_compiles)
            if (avx2_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether avx2 code can be used -- No")
                set (HAVE_AVX2 OFF)
            else()
                message(STATUS "Testing whether avx2 code can be used -- Yes, with -mavx2")
                set (HAVE_AVX2 ON)
            endif()
        else()
            message(STATUS "Testing whether avx2 code can be used -- No")
            set (HAVE_AVX2 OFF)
        endif()
    endif()

    # cache the result
    set (HAVE_AVX2_cached ${HAVE_AVX2} CACHE BOOL "AVX2 available")
    set (avx2_test_cached ON CACHE BOOL "The test for AVX2 has been run")
endif()

if (HAVE_AVX2)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx2")
endif()