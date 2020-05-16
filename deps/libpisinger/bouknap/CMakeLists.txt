cmake_minimum_required(VERSION 3.0)
project(bouknap C)
set(CMAKE_BUILD_TYPE Release)
add_library(bouknap SHARED
	bouknap.c
)
