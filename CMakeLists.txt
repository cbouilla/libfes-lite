cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0076 NEW)

# set the project name
project(feslite VERSION 1.0)

include(FindPython3)
include(CTest)


add_compile_options(-Wall -Werror -O3)

# specify the C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

#####################################################################
# Obtain information from the host (copied from CADO-NFS).

if (DEFINED ENV{NO_SSE})
    message(STATUS "As per $NO_SSE, disabling all simd intrinsics")
else()
    include("config/sse2.cmake")
    include("config/avx2.cmake")
    include("config/avx512.cmake")
endif()
if (DEFINED ENV{NO_NEON})
    message(STATUS "As per $NO_NEON, disabling all ARM NEON intrinsics")
else()
    include("config/neon.cmake")
endif()

configure_file(src/feslite-config.h.in src/feslite-config.h)

add_subdirectory(src)
add_subdirectory(benchmark)

if(BUILD_TESTING)
  add_subdirectory(test)
endif()