# avx512
message(STATUS "Testing whether avx512 code can be used")
if (HAVE_AVX2)
    try_run(avx512_runs avx512_compiles
        ${PROJECT_BINARY_DIR}/config
        ${PROJECT_SOURCE_DIR}/config/AVX512.c)
    if(avx512_compiles)
        if (avx52_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether avx512 code can be used -- No (compile bu does not run)")
            set (HAVE_AVX512 0)
        else()
            message(STATUS "Testing whether avx512 code can be used -- Yes")
            set (HAVE_AVX512 1)
        endif()
    else()
        try_run(avx512_runs avx512_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/AVX512.c
            COMPILE_DEFINITIONS -mavx512f)
        if(avx512_compiles)
            if (avx512_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether avx512 code can be used -- No (compiles with -mavx512f but does not run)")
                set (HAVE_AVX512 0)
            else()
                message(STATUS "Testing whether avx512 code can be used -- Yes, with -mavx512f")
                set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mavx512f")
                set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx512f")
                set (HAVE_AVX512 1)
            endif()
        else()
            message(STATUS "Testing whether avx code can be used -- No (cannot compile)")
            set (HAVE_AVX512 0)
        endif()
    endif()
else()
message(STATUS "Testing whether avx512 code can be used -- skipped")
endif()