                
# avx2
message(STATUS "Testing whether avx2 code can be used")

    try_run(avx2_runs avx2_compiles
        ${PROJECT_BINARY_DIR}/config
        ${PROJECT_SOURCE_DIR}/config/avx2.c)
    if(avx2_compiles)
        if (avx2_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether avx2 code can be used -- No")
            set (HAVE_AVX2 0)
        else()
            message(STATUS "Testing whether avx2 code can be used -- Yes")
            set (HAVE_AVX2 1)
        endif()
    else()
        try_run(avx2_runs avx2_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/avx2.c
            COMPILE_DEFINITIONS -mavx2)
        if(avx2_compiles)
            if (avx2_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether avx2 code can be used -- No")
                set (HAVE_AVX2 0)
            else()
                message(STATUS "Testing whether avx2 code can be used -- Yes, with -mavx2")
                set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx2")
                set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx2")
                set (HAVE_AVX2 1)
            endif()
        else()
            message(STATUS "Testing whether avx2 code can be used -- No")
            set (HAVE_AVX2 0)
        endif()
    endif()
