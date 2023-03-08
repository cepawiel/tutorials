# tutorials

## Build using CMake
```
source /opt/toolchains/dc/kos/environ.sh
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=dreamcast.toolchain.cmake
cmake --build build
```

## Build using Makefiles
```
source /opt/toolchains/dc/kos/environ.sh
make
```