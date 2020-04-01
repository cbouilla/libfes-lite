# AVX512F + AVX512BW

if(AVX512BW_test_cached)    
   
    set (HAVE_AVX512BW ${HAVE_AVX512BW_cached})

else()

    message(STATUS "Testing whether AVX512F+AVX512BW code can be used")
    try_run(avx512_runs avx512_compiles
        ${PROJECT_BINARY_DIR}/config
        ${PROJECT_SOURCE_DIR}/config/AVX512.c)
    if(avx512_compiles)
        if (avx52_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether avx512 code can be used -- No (compile bu does not run)")
            set (HAVE_AVX512BW OFF)
        else()
            message(STATUS "Testing whether avx512 code can be used -- Yes")
            set (HAVE_AVX512BW ON)
        endif()
    else()
        try_run(avx512_runs avx512_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/AVX512.c
            COMPILE_DEFINITIONS -mavx512f -mavx512bw)
        if(avx512_compiles)
            if (avx512_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether avx512 code can be used -- No (compiles with -mavx512f -mavx512bw but does not run)")
                set (HAVE_AVX512BW OFF)
            else()
                message(STATUS "Testing whether avx512 code can be used -- Yes, with -mavx512f -mavx512bw")
                set (HAVE_AVX512BW ON)
            endif()
        else()
            message(STATUS "Testing whether avx code can be used -- No (cannot compile)")
            set (HAVE_AVX512BW OFF)
        endif()
    endif()

    # cache the result
    set (HAVE_AVX512BW_cached ${HAVE_AVX512BW} CACHE BOOL "AVX512F + AVX512BW available")
    set (AVX512BW_test_cached ON CACHE BOOL "The test for AVX512 has been run")
endif()

if(HAVE_AVX512BW)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx512f -mavx512bw")
endif()