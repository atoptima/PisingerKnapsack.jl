__precompile__()

module PisingerKnapsack

const deps_file = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(deps_file)
    include(deps_file)
else
    error("PisingerKnapsack not properly installed. Please run import Pkg; Pkg.build(\"PisingerKnapsack\")")
end

include("Cwrapper.jl")
include("doubleknp.jl")

end # module
