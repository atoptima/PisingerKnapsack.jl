# PisingerKnapsack.jl

Linux & MacOS
[![Build Status](https://travis-ci.org/atoptima/PisingerKnapsack.jl.svg?branch=master)](https://travis-ci.org/atoptima/PisingerKnapsack.jl)
-- Windows 
[![Build status](https://ci.appveyor.com/api/projects/status/u99j9jm866xarfyp?svg=true)](https://ci.appveyor.com/project/guimarqu/pisingerknapsack-jl)


Please note that **Pisinger's algorithms may be used for academic, non-commercial purposes only.**

This package provides a Julia interface to some [Pisinger's algorithms](http://hjemmesider.diku.dk/~pisinger/codes.html).

## Installation

This package is not registered in the Julia Package Manager.

```julia
    Pkg.add("https://github.com/atoptima/PisingerKnapsack.jl.git")
    Pkg.build("PisingerKnapsack")
```

## Algorithms

Methods return two arguments : `obj` is the total cost of the knapsack and `sol` is a vector
in which the value of the i*th* entry is the number the i*th* item is in the knapsack.

- [Minknap algorithm](http://hjemmesider.diku.dk/~pisinger/minknap.c)

```julia
    obj, sol = minknap(costs::Vector, weights::Vector, capacity::Real)
```

- [Bouknap algorithm](http://hjemmesider.diku.dk/~pisinger/bouknap.c)

```julia
    obj, sol = bouknap(costs::Vector, weights::Vector, itemub::Vector, capacity::Real)
```

## Note
You need cmake and a C compiler to compile Pisinger algorithms. The compilation takes place in `PisingerKnapsack.jl/deps/libpisinger/`. The structure of the folder is : 

```
libpisinger
├── bouknap
│   └── CMakeLists.txt
├── minknap
│   └── CMakeLists.txt
└── minmcknap
    └── CMakeLists.txt
```
For each algorithm, one subfolder contains a cmake file. The build step download in each subfolder the source code of the corresponding algorithm. Then, it creates a `build` folder, runs `cmake` and `make`. At the end, each subfolder will contain a `build` folder with a dynamic library inside. For example :

```
libpisinger
├── bouknap
│   ├── CMakeLists.txt
│   ├── bouknap.c
│   └── build
│       ├── CMakeCache.txt
│       ├── Makefile
│       └── libbouknap.dylib
```

If the build step does not work, these are the 
steps to build the dynamic libraries of Pisinger's algorithms : 

1. Download source files in Pisinger's website and, for each algorithm, move the corresponding file to `PisingerKnapsack.jl/deps/libpisinger/<algoname>`
2. Create directory `build` in `PisingerKnapsack.jl/deps/libpisinger/<algoname>`
3. Go to the folder `build`, run `cmake ..`, then `make`
4. Create a file `deps.jl` and add inside `const _jl_lib<algoname> "<ABSOLUTE_PATH_TO>/PisingerKnapsack.jl/deps/libpisinger/<algo_name>/build/<dynamic_lib>"`