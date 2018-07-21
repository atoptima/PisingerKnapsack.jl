__precompile__()

module PisingerKnapsack

const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("PisingerKnapsack not properly installed. Please run Pkg.build(\"PisingerKnapsack\") then restart Julia.")
end

include("Cwrapper.jl")
include("MOIwrapper.jl")

export PisingerKnapsackSolver

end # module
