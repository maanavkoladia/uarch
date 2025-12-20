cmake_minimum_required(VERSION 3.27)

project(Lab6 C)

set(EXE_NAME exe.elf)

set(CMAKE_C_FLAGS "-g -Wall -Wextra")

set(CMAKE_C_STANDARD 99)

add_executable(${EXE_NAME} lc3bsim6.c)

