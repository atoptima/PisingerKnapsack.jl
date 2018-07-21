using PisingerKnapsack
using PisingerKnapsack.PisingerKnapsackCInterface

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

include("Cwrapper.jl")





# using JuMP
#
# items = 1:10
# weights = [2 3 4 5 6 3 4 5 6 5]
# profits = [6 4 5 7 6 5 4 5 4 1]
# Capacity = 15
#
# m = Model(solver = PisingerKnapsackOptimizer())
# @variable(m, x[i in items], Bin)
# @constraint(m, knp, sum(weights[i] * x[i] for i in items) <= Capacity)
# @objective(m, Min, sum(profits[i] * x[i] for i in items))
#
# solve(m)
# # write your own tests here
# @test 1 == 2
