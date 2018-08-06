using PisingerKnapsack
using PisingerKnapsack.PisingerKnapsackCInterface
using MathOptInterface

const MOI = MathOptInterface
const PK = PisingerKnapsack
const PKCI = PK.PisingerKnapsackCInterface

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

include("Cwrapper.jl")
include("MOIwrapper.jl")
#include("JuMPinstance.jl")

