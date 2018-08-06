__precompile__()

module PisingerKnapsack

const Double = Float64
const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")

if isfile(depsfile)
    include(depsfile)
else
    error("PisingerKnapsack not properly installed. Please run Pkg.build(\"PisingerKnapsack\") then restart Julia.")
end

include("Cwrapper.jl")
include("doubleknp.jl")
include("modelknp.jl")
include("MOIwrapper.jl")

export PisingerKnapsackOptimizer

end # module
