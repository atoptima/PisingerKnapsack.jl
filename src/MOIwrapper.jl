export PisingerKnapsackOptimizer

using MathOptInterface
using PisingerKnapsack.PisingerKnapsackCInterface

const MOI = MathOptInterface
const MOIU = MathOptInterface.Utilities
const PKCI = PisingerKnapsackCInterface

mutable struct PisingerKnapsackOptimizer <: MOI.AbstractOptimizer
    inner_model::PisingerKnapsackModel
    function PisingerKnapsackOptimizer()
        new(PisingerKnapsackModel())
    end
end

function MOI.optimize!(optimizer::PisingerKnapsackOptimizer)
    optimize!(optimizer.inner_model)
end

function free!(optimizer::PisingerKnapsackOptimizer)
    error("free! : TODO")
end

function MOI.isempty(optimizer::PisingerKnapsackOptimizer)
    return (getnbitems(optimizer.inner_model) == 0)
end

function MOI.empty!(optimizer::PisingerKnapsackOptimizer)
    error("empty! TODO")
end


## TODO : for JuMP model
# function MOI.copy!(optimizer::PisingerKnapsackOptimizer, src::MOI.ModelLike; copynames = false)
#     idxmap = MOIU.IndexMap()

#     # Variables (Items)
#     vis_src = MOI.get(src, MOI.ListOfVariableIndices())
#     additems!(optimizer, idxmap, vis_src)

#     # Constraints (Variables lb & ub + 1 knp constraint)
#     list_of_constraints = MOI.get(src, MOI.ListOfConstraints())
#     nb_knp = 0
#     for (Func, Set) in list_of_constraints
#         if !(MOI.supportsconstraint(optimizer, Func, Set))
#             return MOI.CopyResult(MOI.CopyUnsupportedConstraint,
#                     "PisingerKnapsack MOI Interface does not support constraints of type ($Func, $Set).", nothing)
#         end
#         nb_knp += knpconstraintcounter(optimizer, Func, Set)

#         updateinnermodel!(optimizer, src, idxmap, Func, Set)
#     end

#     (nb_knp != 1) && error("PisingerKnapsackOptimizer can solve only one knapsack problem at a time.")

#     # Objective function
#     obj = MOI.get(src, MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}())
#     setprofits!(optimizer, idxmap, obj)

#     sense = MOI.get(src, MOI.ObjectiveSense())
#     (sense == MOI.MaxSense) || error("PisingerKnapsackOptimizer solves only maximization problems.")

#     return MOI.CopyResult(MOI.CopySuccess, "Model was copied succefully.", MOIU.IndexMap(idxmap.varmap, idxmap.conmap))
# end

## Constraints

MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.ZeroOne}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.Integer}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.GreaterThan}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.LessThan}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.ScalarAffineFunction{Float64}}, ::Type{<:MOI.LessThan}) = true

function MOI.addconstraint!(optimizer::PisingerKnapsackOptimizer, f::F, s::S) where {F,S}
    loadconstraint!(optimizer, f, s)
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, f::MOI.SingleVariable, s::MOI.ZeroOne)
    # Nothing to do
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, f::MOI.SingleVariable, s::MOI.Integer)
    # Nothing to do
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, f::MOI.SingleVariable, s::MOI.GreaterThan)
    (s.lower != 0) && error("Variables lower bounds must be 0.")
    # Nothing more to do for now
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, f::MOI.SingleVariable, s::MOI.LessThan)
    ub = Integer(floor(s.upper))
    (s.upper > ub) && error("Upper bound of variables must be integer.")
    #varid = f.variable.value
    setitemub!(optimizer.inner_model, varid, ub)
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, f::MOI.ScalarAffineFunction{Float64}, s::MOI.LessThan)
    for term in f.terms
        weight = Integer(floor(term.coefficient))
        (term.coefficient > weight) && error("Weight of items must be integer.")
        varid = term.variable_index.value
        setweight!(optimizer.inner_model, varid, weight)
    end
    capacity = Integer(floor(s.upper))
    (s.upper > capacity) && error("Capacity of knapsack must be integer.")
    setcapacity!(optimizer.inner_model, capacity)
end

## Variables

MOI.canaddvariable(optimizer::PisingerKnapsackOptimizer) = true

function MOI.addvariable!(optimizer::PisingerKnapsackOptimizer)
    varid = additem!(optimizer.inner_model)
    return MOI.VariableIndex(varid)
end

function MOI.addvariables!(optimizer::PisingerKnapsackOptimizer, n::Int)
    return [MOI.addvariable!(optimizer) for i in 1:n]
end

## Objective function

function MOI.canset(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveFunction{F}) where F <: MOI.ScalarAffineFunction{Float64}
    return true
end

function MOI.set!(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveFunction{F}, obj::F) where F <: MOI.ScalarAffineFunction{Float64}
    for term in obj.terms
        varid = term.variable_index.value
        setprofit!(optimizer.inner_model, varid, term.coefficient)
    end
end

function MOI.canset(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveFunction{F}) where F <: MOI.ScalarAffineFunction{Int64}
    return true
end


function MOI.set!(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveFunction{F}, obj::F) where F <: MOI.ScalarAffineFunction{Int64}
    for term in obj.terms
        varid = term.variable_index.value
        setprofit!(optimizer.inner_model, varid, term.coefficient)
    end
end

MOI.canset(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveSense) = false

function MOI.set!(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveSense, sense)
    if sense == MOI.MinSense
        error("PisingerKnapsackOptimizer supports only maximization.")
    end
end

## After the optimization : retrieve the solution, ...

MOI.canget(optimizer::PisingerKnapsackOptimizer, ::MOI.TerminationStatus) = true
function MOI.get(optimizer::PisingerKnapsackOptimizer, ::MOI.TerminationStatus)
    if optimized(optimizer.inner_model)
        return MOI.Success
    end
    return MOI.OtherError
end

MOI.canget(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveValue) = true
function MOI.get(optimizer::PisingerKnapsackOptimizer, ::MOI.ObjectiveValue)
    return objectivevalue(optimizer.inner_model)
end

function MOI.get(optimizer::PisingerKnapsackOptimizer, ::MOI.ResultCount)
    if optimized(optimizer.inner_model)
        return 1
    end
    return 0
end

function MOI.get(optimizer::PisingerKnapsackOptimizer, ::MOI.PrimalStatus)
    if optimized(optimizer.inner_model)
        return MOI.FeasiblePoint
    end
    return MOI.UnknownResultStatus
end

MOI.canget(optimizer::PisingerKnapsackOptimizer, ::MOI.VariablePrimal) = true
function MOI.get(optimizer::PisingerKnapsackOptimizer, ::MOI.VariablePrimal, vars::Vector{MOI.VariableIndex})
    varvals = Vector{Double}()
    for var in vars
        push!(varvals, variablevalue(optimizer.inner_model, var.value))
    end
    return varvals
end
