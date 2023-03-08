cmake_minimum_required(VERSION 3.1)

project(SFX)

add_executable(${PROJECT_NAME}
  main.c
)

# Add Romdisk to Executable
generate_romdisk(${PROJECT_NAME} romdisk ${CMAKE_CURRENT_SOURCE_DIR}/romdisk)

# Build CDI using mkdcdisc
generate_cdi(${PROJECT_NAME}
  NO_PADDING
  # NO_MR
  GAME_NAME "${PROJECT_NAME}"
  AUTHOR "DreamcastWiki tutorials"
  # CDDA 
  # file1.wav 
  # file2.wav
  FILE 
  # ${CMAKE_CURRENT_SOURCE_DIR}/main.c 
  # ${CMAKE_CURRENT_SOURCE_DIR}/README
  DIRECTORY 
  # ${CMAKE_CURRENT_SOURCE_DIR}/assets 
  # ${CMAKE_CURRENT_SOURCE_DIR}/images
)

