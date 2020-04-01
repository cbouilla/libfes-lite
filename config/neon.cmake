# arm NEON

if(neon_test_cached)    
   
    set (HAVE_NEON ${HAVE_NEON_cached})

    # ARM NEON
    message(STATUS "Testing whether ARM NEON code can be used")
    try_run(neon_runs neon_compiles
                ${PROJECT_BINARY_DIR}/config
                ${PROJECT_SOURCE_DIR}/config/neon.c)
    if(neon_compiles)
        if (neon_runs MATCHES FAILED_TO_RUN)
            message(STATUS "Testing whether ARM NEON code can be used -- No")
            set (HAVE_NEON OFF)
        else()
            message(STATUS "Testing whether ARM NEON code can be used -- Yes")
            set (HAVE_NEON ON)
        endif()
    else()
        try_run(neon_runs neon_compiles
            ${PROJECT_BINARY_DIR}/config
            ${PROJECT_SOURCE_DIR}/config/neon.c
            COMPILE_DEFINITIONS -mfpu=neon)
        if(neon_compiles)
            if (neon_runs MATCHES FAILED_TO_RUN)
                message(STATUS "Testing whether ARM NEON code can be used -- No")
    	    set (HAVE_NEON OFF)
            else()
                message("${neon_runs}")
                message(STATUS "Testing whether ARM NEON code can be used -- Yes, with -mfpu=neon")
                set (HAVE_NEON ON)
            endif()
        else()
            message(STATUS "Testing whether ARM NEON code can be used -- No (cannot compile)")
            set (HAVE_NEON OFF)
        endif()
    endif()

    # cache the result
    set (HAVE_NEON_cached ${HAVE_NEON} CACHE BOOL "ARM NEON available")
    set (neon_test_cached ON CACHE BOOL "The test for NEON has been run")
endif()

if (HAVE_NEON)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfpu=neon")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon")
endif()