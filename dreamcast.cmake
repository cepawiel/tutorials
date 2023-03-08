cmake_minimum_required(VERSION 3.7)

### Helper Function for Generating Romdisk ###
function(generate_romdisk target romdiskName romdiskPath)
  set(obj ${CMAKE_CURRENT_BINARY_DIR}/${romdiskName}.o)
  set(img ${CMAKE_CURRENT_BINARY_DIR}/${romdiskName}.img)

  # Variable holding all files in the romdiskPath folder
  # CONFIGURE_DEPENDS causes the folder to always be rechecked
  # at build time not only when CMake is re-run
  file(GLOB romdiskFiles CONFIGURE_DEPENDS
       "${romdiskPath}/*"
  )
  
  # Custom Command to generate romdisk image from folder
  # Only run when folder contents have changed by depending on 
  # the romdiskFiles variable
  add_custom_command(
    OUTPUT ${img}
    COMMAND $ENV{KOS_GENROMFS} -f ${img} -d ${romdiskPath} -v
    DEPENDS ${romdiskFiles}
  )

  # Custom Command to generate romdisk object file from image
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${romdiskName}.o
    COMMAND $ENV{KOS_BASE}/utils/bin2o/bin2o ${img} ${romdiskName} ${obj}
    DEPENDS ${img}
  )

  # Append romdisk object to target
  target_sources(${target} PRIVATE ${obj})
endfunction()

function(generate_cdi target)
  set(elf       $<TARGET_FILE:${target}>)
  set(cdi       ${CMAKE_CURRENT_BINARY_DIR}/${target}.cdi)
  set(dep_cdi   ${target}_cdi)
  
  # Find mkdcdisc executable
  find_program(MKDCDISC mkdcdisc REQUIRED)
  if(NOT MKDCDISC)
    message(FATAL_ERROR "Unable to find mkdcdisc executable add to env $PATH or specify path with -DMKDCDISC=<path to mkdcdisc>")
  endif()

  set(options NO_PADDING NO_MR)
  set(oneValueArgs GAME_NAME AUTHOR)
  set(multiValueArgs CDDA FILE DIRECTORY)
  cmake_parse_arguments(
    GENERATE_CDI
    "${options}" 
    "${oneValueArgs}"
    "${multiValueArgs}" 
    ${ARGN}
  )

  set(ARG_LIST "-v" "3")
  set(WATCH_LIST ${elf})

  ### Start of argument-less parameters ###
  if(GENERATE_CDI_NO_PADDING)
    list(APPEND ARG_LIST "--no-padding")
  endif()

  if(GENERATE_CDI_NO_MR)
    list(APPEND ARG_LIST "--no-mr")
  endif()
  ### End of argument-less parameters ###


  ### Start of single argument parameters ###
  if(DEFINED GENERATE_CDI_GAME_NAME)
    list(APPEND ARG_LIST "--name" "\"${GENERATE_CDI_GAME_NAME}\"")
  endif()

  if(DEFINED GENERATE_CDI_AUTHOR)
    list(APPEND ARG_LIST "--author" "\"${GENERATE_CDI_AUTHOR}\"")
  endif()
  ### End of single argument parameters ###


  ### Start of multi argument parameters ###
  if(DEFINED GENERATE_CDI_CDDA)
    foreach(cdda IN LISTS GENERATE_CDI_CDDA)
      list(APPEND ARG_LIST "--cdda" ${cdda})
    endforeach()
  endif()

  if(DEFINED GENERATE_CDI_FILE)
    foreach(file IN LISTS GENERATE_CDI_FILE)
      list(APPEND ARG_LIST "--file" ${file})
    endforeach()
  endif()

  if(DEFINED GENERATE_CDI_DIRECTORY)
    foreach(dir IN LISTS GENERATE_CDI_DIRECTORY)
      list(APPEND ARG_LIST "--directory" ${dir})
    endforeach()
  endif()
  ### End of multi argument parameters ###


  add_custom_command(
    OUTPUT ${dep_cdi}
    COMMAND ${MKDCDISC} -e ${elf} -o ${cdi} ${ARG_LIST}
    DEPENDS ${elf}
  )

  add_custom_target(${target}.cdi ALL
    DEPENDS ${dep_cdi}
  )

  
endfunction()

### Function to Enable SH4 Math Optimizations ###
function(enable_sh4_math)
  if(NOT ${PLATFORM_DREAMCAST})
    message(WARN " PLATFORM_DREAMCAST not set, skipping SH4 Math flags")
    return()
  endif()

  message(INFO " Enabling SH4 Math Optimizations")
  
  include(CheckCCompilerFlag)
  check_c_compiler_flag("-mfsrra" COMPILER_HAS_FSRRA)
  check_c_compiler_flag("-mfsca"  COMPILER_HAS_FSCA)
  if(COMPILER_HAS_FSRRA)
    add_compile_options(-mfsrra)
  else()
    message(WARN " Must have GCC4.8 or later for -mfsrra to be enabled")
  endif()

  if(COMPILER_HAS_FSCA)
    add_compile_options(-mfsca)
  else()
    message(WARN " Must have GCC4.8 or later for -mfsca to be enabled")
  endif()

  add_compile_options(-ffast-math)
endfunction()