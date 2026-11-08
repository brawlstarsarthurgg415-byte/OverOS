cmake_minimum_required(VERSION 3.16)
project(OverOSCore VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(overos-init init/overos-init.c)
target_compile_options(overos-init PRIVATE -Wall -Wextra -Wpedantic -Wconversion)

add_executable(overos-hardware-info services/hardware-info.cpp)
target_compile_options(overos-hardware-info PRIVATE -Wall -Wextra -Wpedantic)
