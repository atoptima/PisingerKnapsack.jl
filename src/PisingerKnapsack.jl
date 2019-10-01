__precompile__()

module PisingerKnapsack

const Double = Float64

include("Cwrapper.jl")
include("doubleknp.jl")
#include("modelknp.jl")
#include("MOIwrapper.jl")
#export PisingerKnapsackOptimizer

end # module
