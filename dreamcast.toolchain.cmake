# CMake Toolchain file for targeting the Dreamcast or NAOMI with CMake.
#  (c)2023 Falco Girgis, Luke Benstead
#
# This file is to be passed to CMake when compiling a regular CMake project
# to cross-compile for the Dreamcast, using the KOS environment and settings.
#
#     cmake /path/to/src -DCMAKE_TOOLCHAIN_FILE=${KOS_BASE}/kos/utils/cmake/dreamcast.toolchain.cmake
#
#   or alternatively:
#
#     cmake /path/to/src -DCMAKE_TOOLCHAIN_FILE=${KOS_CMAKE_TOOLCHAIN}
#
# The toolchain enables the options required for the compiler to use the 
# special SH4 instructions for sin/cos and invSqrt. Note that even when 
# these options are present, they are not activated unless -ffast-math 
# is also provied. Typically you will want to provide a project-level 
# option for enabling this flag, which will make the toolchain's SH4 
# instruction flags also take effect.
#
# Frame pointers are enabled in debug builds as these are required for 
# stack traces and GDB. They are disabled in release.
# 
# The original toolchain file was created by Kazade for the Simulant 
# engine who has graciously allowed the rest of the scene to warez it. 
#
# Special thanks to Matt Godbolt of Compiler Explorer, for supporting
# the SH toolchains, which allowed us to figure out the precise magical
# incantations of compiler flags for fast math.  

cmake_minimum_required(VERSION 3.23)

#### Include Guard ####
if(__KOS_TOOLCHAIN_FILE_VAR__)
  return()
endif()
set(__KOS_TOOLCHAIN_FILE_VAR__ TRUE)

#### Check Required Environment Variables ####
if(NOT DEFINED ENV{KOS_BASE})
  message(FATAL_ERROR "Environment Variable KOS_BASE not set")
endif()

if(NOT DEFINED ENV{KOS_CC_BASE})
  message(FATAL_ERROR "Environment Variable KOS_CC_BASE not set")
endif()

if(NOT DEFINED ENV{KOS_SUBARCH})
  message(FATAL_ERROR "Environment Variable KOS_CC_BASE not set")
endif()

if(NOT DEFINED ENV{KOS_PORTS})
  message(FATAL_ERROR "Environment Variable KOS_CC_BASE not set")
endif()

##### Configure CMake System #####
set(CMAKE_SYSTEM_NAME Generic-ELF)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR SH4)
set(PLATFORM_DREAMCAST TRUE)

##### Configure Cross-Compiler #####
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_C_COMPILER $ENV{KOS_CC_BASE}/bin/sh-elf-gcc)
set(CMAKE_CXX_COMPILER $ENV{KOS_CC_BASE}/bin/sh-elf-g++)

set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

# Never use the CMAKE_FIND_ROOT_PATH to find programs with find_program()
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

##### Add Platform-Specific #defines #####
ADD_DEFINITIONS(
    -D__DREAMCAST__
    -D_arch_dreamcast
)

if($ENV{KOS_SUBARCH} MATCHES naomi)
    ADD_DEFINITONS(
        -D__NAOMI__
        -D_arch_sub_naomi
    )
else()
    ADD_DEFINITIONS(-D_arch_sub_pristine)
endif()

##### Configure Build Flags #####
add_compile_options(-ml -m4-single-only -ffunction-sections -fdata-sections)

set(ENABLE_DEBUG_FLAGS   $<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>)
set(ENABLE_RELEASE_FLAGS $<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>)

add_compile_options(
    "$<${ENABLE_DEBUG_FLAGS}:-DFRAME_POINTERS;-fno-omit-frame-pointer>"
    "$<${ENABLE_RELEASE_FLAGS}:-fomit-frame-pointer>"
    )

set(CMAKE_ASM_FLAGS "")
set(CMAKE_ASM_FLAGS_RELEASE "")

##### Configure Include Directories #####
set(CMAKE_SYSTEM_INCLUDE_PATH "${CMAKE_SYSTEM_INCLUDE_PATH} $ENV{KOS_BASE}/include $ENV{KOS_BASE}/kernel/arch/dreamcast/include $ENV{KOS_BASE}/addons/include $ENV{KOS_PORTS}/include")

INCLUDE_DIRECTORIES(
    $ENV{KOS_BASE}/include
    $ENV{KOS_BASE}/kernel/arch/dreamcast/include
    $ENV{KOS_BASE}/addons/include
    $ENV{KOS_PORTS}/include
)

##### Configure Libraries #####
set(CMAKE_SYSTEM_LIBRARY_PATH "${CMAKE_SYSTEM_LIBRARY_PATH} $ENV{KOS_BASE}/addons/lib/dreamcast $ENV{KOS_PORTS}/lib")

if($ENV{KOS_SUBARCH} MATCHES naomi)
  add_link_options(-Wl,-Ttext=0x8c020000 -T$ENV{KOS_BASE}/utils/ldscripts/shlelf-naomi.xc)
else()
  add_link_options(-Wl,-Ttext=0x8c010000 -T$ENV{KOS_BASE}/utils/ldscripts/shlelf.xc)
endif()

add_link_options(-ml -m4-single-only -Wl,--gc-sections -nodefaultlibs)

LINK_DIRECTORIES(
    $ENV{KOS_BASE}/lib/dreamcast
    $ENV{KOS_BASE}/addons/lib/dreamcast
    $ENV{KOS_PORTS}/lib
)

add_link_options(-L$ENV{KOS_BASE}/lib/dreamcast -L$ENV{KOS_BASE}/addons/lib/dreamcast -L$ENV{KOS_PORTS}/lib)
LINK_LIBRARIES(-Wl,--start-group -lstdc++ -lkallisti -lc -lgcc -Wl,--end-group m)
