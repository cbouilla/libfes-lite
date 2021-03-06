cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0076 NEW)

# set the project name
project(feslite VERSION 1.0 
	LANGUAGES C ASM
	HOMEPAGE_URL https://github.com/cbouilla/libfes-lite)

include(FindPython3)
include(CTest)

find_package (Python3 COMPONENTS Interpreter) # Development

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build." FORCE)
endif()

add_compile_options(-Wall -Werror -O3 -Wno-unused-function)

# specify the C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

# OpenMP ?
find_package(OpenMP)

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