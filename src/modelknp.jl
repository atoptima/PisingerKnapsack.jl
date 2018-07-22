const IntegerDouble = Union{Integer, Double}

abstract type PisingerAlgo end
struct Knap <: PisingerAlgo end
struct BouKnap <: PisingerAlgo end
struct DoubleMinKnap <: PisingerAlgo end
struct MinKnap <: PisingerAlgo end

mutable struct PisingerKnapsackModel
    nb_items::Integer
    profits::Vector{IntegerDouble}
    weights::Vector{Integer}
    capacity::Integer
    items_ub::Vector{Integer}
    items_lb::Vector{Integer}
    # TODO Solution
    function PisingerKnapsackModel()
        new(0, Vector{IntegerDouble}(), Vector{Integer}(), 0, Vector{Integer}(), Vector{Integer}())
    end
end

function additem!(model::PisingerKnapsackModel)
    model.nb_items += 1
    varid = model.nb_items
    push!(model.profits, 0)
    push!(model.weights, 0)
    push!(model.items_ub, 1)
    push!(model.items_lb, 0)
    return varid
end

getnbitems(model::PisingerKnapsackModel) = model.nb_items

function setprofit!(model::PisingerKnapsackModel, varid::Int, profit::IntegerDouble)
    model.profits[varid] += profit
end

function setweight!(model::PisingerKnapsackModel, varid::Int, weight::Integer)
    model.weights[varid] = weight
end

function setitemub!(model::PisingerKnapsackModel, varid::Int, ub::Integer)
    model.items_ub[varid] = ub
end

function setitemlb!(model::PisingerKnapsackModel, varid::Int, lb::Integer)
    model.items_lb[varid] = lb
end

function setcapacity!(model::PisingerKnapsackModel, capacity::Integer)
    model.capacity = capacity
end

function optimize!(model::PisingerKnapsackModel)
    algo, sort_items = preprocessing(model)
    # Work on data (eliminate items with negative profit for instance...)
    profits = model.profits
    weights = model.weights
    lbs = model.items_lb
    ubs = model.items_ub
    # Solve the model
    (val, sol) = solve(model.profits, weights, lbs, ubs, model.capacity, algo)
    # Store the solution
    # TODO
end

function preprocessing(model::PisingerKnapsackModel)
    integer_profits = mapreduce(p -> (p == floor(p)), &, model.profits)
    zero_lb_items = mapreduce(lb -> (lb == 0), &, model.items_lb)
    one_ub_items = mapreduce(ub -> (ub == 1), &, model.items_ub)
    algo = Knap()
    if integer_profits && one_ub_items
        algo = MinKnap()
    elseif !integer_profits && one_ub_items
        algo = DoubleMinKnap()
    elseif integer_profits && !one_ub_items
        algo = BouKnap()
    end
    return typeof(algo), !zero_lb_items
end

function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:PisingerAlgo})
     error("No algorithm found to solve the instance.")
end

function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:MinKnap})
    profits = Vector{Integer}(profits)
    return PKCI.minknap(profits, weights, capacity)
end

function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:DoubleMinKnap})
    profits = Vector{Double}(profits)
    return doubleminknap(profits, weights, capacity)
end

function solve(profits, weights, lbs, ubs, capacity, algo::Type{<:BouKnap})
    profits = Vector{Integer}(profits)
    return PKCI.bouknap(profits, weights, ubs, capacity)
end
