const IntegerDouble = Union{Integer, Double}

@enum PisingerAlgo BouKnap DoubleMinKnap MinKnap NotFound

mutable struct PisingerKnapsackModel
    nb_items::Integer
    profits::Vector{IntegerDouble}
    weights::Vector{Integer}
    capacity::Integer
    items_ub::Vector{Integer}
    items_lb::Vector{Integer}
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
    @show model
    algo, sort_items = eval_work_to_be_done(model)
    #solve(profits, weights, lbs, ubs, capacity, algo)
end

function eval_work_to_be_done(model::PisingerKnapsackModel)
    integer_profits = mapreduce(p -> (p == floor(p)), &, model.profits)
    zero_lb_items = mapreduce(lb -> (lb == 0), &, model.items_lb)
    one_ub_items = mapreduce(ub -> (ub == 1), &, model.items_ub)
    algo = NotFound
    if integer_profits && one_ub_items
        algo = MinKnap
    elseif !integer_profits && one_ub_items
        algo = DoubleMinKnap
    elseif integer_profits && !one_ub_items
        algo = BouKnap
    end
    return algo, !zero_lb_items
end
