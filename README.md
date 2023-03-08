# tutorials

## Build using CMake
### Command Line
```
source /opt/toolchains/dc/kos/environ.sh
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=dreamcast.toolchain.cmake
cmake --build build
```
### VSCode
```
source /opt/toolchains/dc/kos/environ.sh
code .
```

## Build using Makefiles
```
source /opt/toolchains/dc/kos/environ.sh
make
```