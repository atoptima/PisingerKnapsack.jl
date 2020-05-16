cmake_minimum_required(VERSION 3.0)
project(minknap C)
set(CMAKE_BUILD_TYPE Release)
add_library(minknap SHARED
	minknap.c
)
