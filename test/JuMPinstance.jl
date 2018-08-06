using JuMP

items = 1:10
weights = [2 3 4 5 6 3 4 5 6 5]
profits = [6 4 5 7 6 5 4 5 4 1]
Capacity = 15

optimizer = PK.PisingerKnapsackOptimizer()
m = Model(optimizer = optimizer)
@variable(m, 0 <= x[i in items] <= 5, Int)
@constraint(m, knp, sum(weights[i] * x[i] for i in items) <= Capacity)
@objective(m, Max, sum(profits[i] * x[i] for i in items))

s = optimize(m)

@show getobjectivevalue(m)
# @show getvalue(x)
# @show getvalue(x[2])
# write your own tests here
# @test 1 == 2