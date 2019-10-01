# const IntDouble = Union{Int, Double}

# abstract type PisingerAlgo end
# struct Knap <: PisingerAlgo end
# struct BouKnap <: PisingerAlgo end
# struct DoubleMinKnap <: PisingerAlgo end
# struct MinKnap <: PisingerAlgo end

# mutable struct PisingerKnapsackModel
#     nb_items::Int
#     profits::Vector{IntDouble}
#     weights::Vector{Int}
#     capacity::Int
#     items_ub::Vector{Int}
#     items_lb::Vector{Int}
#     optimized::Bool
#     obj_val::Double
#     var_val::Vector{Double}
# end

# function PisingerKnapsackModel()
#     return PisingerKnapsackModel(0, Vector{IntDouble}(), Vector{Int}(), 0, Vector{Int}(), Vector{Int}(), false, 0.0, Vector{Double}())
# end

# function additem!(model::PisingerKnapsackModel)
#     model.nb_items += 1
#     varid = model.nb_items
#     push!(model.profits, 0)
#     push!(model.weights, 0)
#     push!(model.items_ub, 1)
#     push!(model.items_lb, 0)
#     push!(model.var_val, 0.0)
#     return varid
# end

# getnbitems(model::PisingerKnapsackModel) = model.nb_items

# function setprofit!(model::PisingerKnapsackModel, varid::Int, profit::IntDouble)
#     model.profits[varid] += profit
# end

# function setweight!(model::PisingerKnapsackModel, varid::Int, weight::Int)
#     model.weights[varid] = weight
# end

# function setitemub!(model::PisingerKnapsackModel, varid::Int, ub::Int)
#     model.items_ub[varid] = ub
# end

# function setitemlb!(model::PisingerKnapsackModel, varid::Int, lb::Int)
#     model.items_lb[varid] = lb
# end

# function setcapacity!(model::PisingerKnapsackModel, capacity::Int)
#     model.capacity = capacity
# end

# function optimized(model::PisingerKnapsackModel)
#     return model.optimized
# end

# function objectivevalue(model::PisingerKnapsackModel)
#     return model.obj_val
# end

# function variablevalue(model::PisingerKnapsackModel, varid::Int)
#     return model.var_val[varid]
# end

# function optimize!(model::PisingerKnapsackModel)
#     algo, sort_items = preprocessing(model)
#     # Work on data (eliminate items with negative profit for instance...)
#     profits = deepcopy(model.profits)
#     weights = deepcopy(model.weights)
#     lbs = deepcopy(model.items_lb)
#     ubs = deepcopy(model.items_ub)
#     capacity = deepcopy(model.capacity)
#     # Solve the model
#     (val, sol) = solve(profits, weights, lbs, ubs, capacity, algo)
#     # Store the solution
#     model.obj_val = val
#     model.var_val = sol
#     model.optimized = true
#     return
# end

# function preprocessing(model::PisingerKnapsackModel)
#     integer_profits = mapreduce(p -> (p == floor(p)), &, model.profits)
#     zero_lb_items = mapreduce(lb -> (lb == 0), &, model.items_lb)
#     one_ub_items = mapreduce(ub -> (ub == 1), &, model.items_ub)
#     algo = Knap()
#     if integer_profits && one_ub_items
#         algo = MinKnap()
#     elseif !integer_profits && one_ub_items
#         algo = DoubleMinKnap()
#     elseif integer_profits && !one_ub_items
#         algo = BouKnap()
#     end
#     return typeof(algo), !zero_lb_items
# end

# function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:PisingerAlgo})
#      error("No algorithm found to solve the instance.")
# end

# function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:MinKnap})
#     profits = Vector{Int}(profits)
#     return minknap(profits, weights, capacity)
# end

# function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:DoubleMinKnap})
#     profits = Vector{Double}(profits)
#     return doubleminknap(profits, weights, capacity)
# end

# function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:BouKnap})
#     profits = Vector{Int}(profits)
#     return bouknap(profits, weights, ubs, capacity)
# end
