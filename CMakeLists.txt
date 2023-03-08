cmake_minimum_required(VERSION 3.7)

# Outputs compile_commands.json which shows per file compile flags
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Temp override local toolchain file
set(CMAKE_TOOLCHAIN_FILE "dreamcast.toolchain.cmake")

### Start Check Toolchain File ###
if(DEFINED CMAKE_TOOLCHAIN_FILE)
  # Toolchain file was manually specified
elseif(DEFINED ENV{KOS_CMAKE_TOOLCHAIN})
  # KOS_CMAKE_TOOLCHAIN file was provided
  set(CMAKE_TOOLCHAIN_FILE "$ENV{KOS_CMAKE_TOOLCHAIN}" CACHE PATH "toolchain file")
elseif(DEFINED ENV{KOS_BASE})
  # Try and use default toolchain file relative to $KOS_BASE
  set(CMAKE_TOOLCHAIN_FILE "$ENV{KOS_BASE}/utils/cmake/dreamcast.toolchain.cmake" CACHE PATH "toolchain file")
else()
  message(FATAL_ERROR "Unable to find dreamcast.toolchain.cmake")
  message(FATAL_ERROR "Set $KOS_CMAKE_TOOLCHAIN or $KOS_BASE environment variable")
endif()
message(STATUS "Using Toolchain File: ${CMAKE_TOOLCHAIN_FILE}")
### End Check Toolchain File ###

# Include Dreamcast Helper Functions
include(dreamcast.cmake REQUIRED)

project(tutorials)

# Enable Optional SH4 Optimization Flags
enable_sh4_math()

# Include Subdirectories
add_subdirectory(Audio)


