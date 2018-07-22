const IntegerDouble = Union{Integer, Double}

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

function optimize!(model::PisingerKnapsackModel)
    error("TODO : optimize!")
end
