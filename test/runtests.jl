using PisingerKnapsack
using PisingerKnapsack.PisingerKnapsackCInterface

const PK = PisingerKnapsack

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

include("Cwrapper.jl")

using JuMP

items = 1:10
weights = [2 3 4 5 6 3 4 5 6 5]
profits = [6 4 5 7 6 5 4 5 4 1]
Capacity = 15

m = Model(optimizer = PK.PisingerKnapsackOptimizer())
@variable(m, 0 <= x[i in items] <= 5, Int)
@constraint(m, knp, sum(weights[i] * x[i] for i in items) <= Capacity)
@objective(m, Max, sum(profits[i] * x[i] for i in items))

optimize(m)
# write your own tests here
@test 1 == 2
