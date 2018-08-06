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

# using JuMP
#
# items = 1:10
# weights = [2 3 4 5 6 3 4 5 6 5]
# profits = [6 4 5 7 6 5 4 5 4 1]
# Capacity = 15

# optimizer = PK.PisingerKnapsackOptimizer()
# m = Model(optimizer = optimizer)
# @variable(m, 0 <= x[i in items] <= 5, Int)
# @constraint(m, knp, sum(weights[i] * x[i] for i in items) <= Capacity)
# @objective(m, Max, sum(profits[i] * x[i] for i in items))
#
# s = optimize(m)
#
# termination_status = MOI.get(optimizer, MOI.TerminationStatus())
# println("Solver terminated with status $termination_status")
#
# objvalue = MOI.canget(optimizer, MOI.ObjectiveValue()) ? MOI.get(optimizer, MOI.ObjectiveValue()) : NaN
# println("Objective value is $objvalue")
#
# primal_variable_result = MOI.get(optimizer, MOI.VariablePrimal(), x)
#
# @show objvalue
# @show primal_variable_result


# @show getobjectivevalue(m)
# @show getvalue(x)
# @show getvalue(x[2])
# write your own tests here
# @test 1 == 2
