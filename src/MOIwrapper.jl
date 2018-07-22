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

"""
    optimize!(optimizer::AbstractOptimizer)

Start the solution procedure.
"""
function MOI.optimize!(optimizer::PisingerKnapsackOptimizer)
    optimize!(optimizer.inner_model)
end

"""
    free!(optimizer::AbstractOptimizer)

Release any resources and memory used by the optimizer.
Note that the Julia garbage collector takes care of this automatically, but automatic collection cannot always be forced.
This method is useful for more precise control of resources, especially in the case of commercial solvers with licensing restrictions on the number of concurrent runs.
Users must discard the optimizer object after this method is invoked.
"""
function free!(optimizer::PisingerKnapsackOptimizer)
    error("free! : TODO")
end

"""
    isempty(model::ModelLike)

Returns `false` if the `model` has any model attribute set or has any variables or constraints.
Note that an empty model can have optimizer attributes set.
"""
function MOI.isempty(optimizer::PisingerKnapsackOptimizer)
    return (getnbitems(optimizer.inner_model) == 0)
end

"""
    empty!(model::ModelLike)

Empty the model, that is, remove all variables, constraints and model attributes but not optimizer attributes.
"""
function MOI.empty!(optimizer::PisingerKnapsackOptimizer)
    error("empty! TODO")
end

"""
    copy!(dest::ModelLike, src::ModelLike; copynames=true, warnattributes=true)::CopyResult

Copy the model from `src` into `dest`. The target `dest` is emptied, and all
previous indices to variables or constraints in `dest` are invalidated. Returns
a `CopyResult` object. If the copy is successful, the `CopyResult` contains a
dictionary-like object that translates variable and constraint indices from the
`src` model to the corresponding indices in the `dest` model.
"""
function MOI.copy!(optimizer::PisingerKnapsackOptimizer, src::MOI.ModelLike; copynames = false)
    idxmap = MOIU.IndexMap()

    # Variables (Items)
    vis_src = MOI.get(src, MOI.ListOfVariableIndices())
    additems!(optimizer, idxmap, vis_src)

    # Constraints (Variables lb & ub + 1 knp constraint)
    list_of_constraints = MOI.get(src, MOI.ListOfConstraints())
    nb_knp = 0
    for (Func, Set) in list_of_constraints
        if !(MOI.supportsconstraint(optimizer, Func, Set))
            return MOI.CopyResult(MOI.CopyUnsupportedConstraint,
                    "PisingerKnapsack MOI Interface does not support constraints of type ($Func, $Set).", nothing)
        end
        nb_knp += knpconstraintcounter(optimizer, Func, Set)

        updateinnermodel!(optimizer, src, idxmap, Func, Set)
    end

    (nb_knp != 1) && error("PisingerKnapsackOptimizer can solve only one knapsack problem at a time.")

    # Objective function
    obj = MOI.get(src, MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}())
    setprofits!(optimizer, idxmap, obj)

    sense = MOI.get(src, MOI.ObjectiveSense())
    (sense == MOI.MaxSense) || error("PisingerKnapsackOptimizer solves only maximization problems.")

    return MOI.CopyResult(MOI.CopySuccess, "Model was copied succefully.", MOIU.IndexMap(idxmap.varmap, idxmap.conmap))
end

"""
    supportsconstraint(model::ModelLike, ::Type{F}, ::Type{S})::Bool where {F<:AbstractFunction,S<:AbstractSet}

Return a `Bool` indicating whether `model` supports `F`-in-`S` constraints, that is,
`copy!(model, src)` does not return `CopyUnsupportedConstraint` when `src` contains `F`-in-`S` constraints.
If `F`-in-`S` constraints are only not supported in specific circumstances, e.g. `F`-in-`S` constraints cannot be combined with another type of constraint, it should still return `true`.
"""
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.ZeroOne}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.Integer}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.GreaterThan}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.SingleVariable}, ::Type{<:MOI.LessThan}) = true
MOI.supportsconstraint(::PisingerKnapsackOptimizer, ::Type{<:MOI.ScalarAffineFunction{Float64}}, ::Type{<:MOI.LessThan}) = true

"""
    canget(optimizer::AbstractOptimizer, attr::AbstractOptimizerAttribute)::Bool
Return a `Bool` indicating whether `optimizer` currently has a value for the attribute specified by attr type `attr`.
    canget(model::ModelLike, attr::AbstractModelAttribute)::Bool
Return a `Bool` indicating whether `model` currently has a value for the attribute specified by attribute type `attr`.
    canget(model::ModelLike, attr::AbstractVariableAttribute, ::Type{VariableIndex})::Bool
Return a `Bool` indicating whether `model` currently has a value for the attribute specified by attribute type `attr` applied to *every* variable of the model.
    canget(model::ModelLike, attr::AbstractConstraintAttribute, ::Type{ConstraintIndex{F,S}})::Bool where {F<:AbstractFunction,S<:AbstractSet}
Return a `Bool` indicating whether `model` currently has a value for the attribute specified by attribute type `attr` applied to *every* `F`-in-`S` constraint.
    canget(model::ModelLike, ::Type{VariableIndex}, name::String)::Bool
Return a `Bool` indicating if a variable with the name `name` exists in `model`.
    canget(model::ModelLike, ::Type{ConstraintIndex{F,S}}, name::String)::Bool where {F<:AbstractFunction,S<:AbstractSet}
Return a `Bool` indicating if an `F`-in-`S` constraint with the name `name` exists in `model`.
    canget(model::ModelLike, ::Type{ConstraintIndex}, name::String)::Bool
Return a `Bool` indicating if a constraint of any kind with the name `name` exists in `model`.
### Examples
```julia
canget(model, ObjectiveValue())
canget(model, VariablePrimalStart(), VariableIndex)
canget(model, VariablePrimal(), VariableIndex)
canget(model, ConstraintPrimal(), ConstraintIndex{SingleVariable,EqualTo{Float64}})
canget(model, VariableIndex, "var1")
canget(model, ConstraintIndex{ScalarAffineFunction{Float64},LessThan{Float64}}, "con1")
canget(model, ConstraintIndex, "con1")
```
"""
# TODO MOI.canget(::PisingerKnapsackOptimizer, ::MOI.TerminationStatus) = true
# TODO MOI.canget(::PisingerKnapsackOptimizer, ::MOI.ObjectiveValue) = true
# TODO MOI.canget(::PisingerKnapsackOptimizer, ::MOI.VariablePrimal, ::Type{MOI.VariableIndex}) = true

"""
    get(optimizer::AbstractOptimizer, attr::AbstractOptimizerAttribute)
Return an attribute `attr` of the optimizer `optimizer`.
    get(model::ModelLike, attr::AbstractModelAttribute)
Return an attribute `attr` of the model `model`.
    get(model::ModelLike, attr::AbstractVariableAttribute, v::VariableIndex)
Return an attribute `attr` of the variable `v` in model `model`.
    get(model::ModelLike, attr::AbstractVariableAttribute, v::Vector{VariableIndex})
Return a vector of attributes corresponding to each variable in the collection `v` in the model `model`.
    get(model::ModelLike, attr::AbstractConstraintAttribute, c::ConstraintIndex)
Return an attribute `attr` of the constraint `c` in model `model`.
    get(model::ModelLike, attr::AbstractConstraintAttribute, c::Vector{ConstraintIndex{F,S}})
Return a vector of attributes corresponding to each constraint in the collection `c` in the model `model`.
    get(model::ModelLike, ::Type{VariableIndex}, name::String)
If a variable with name `name` exists in the model `model`, return the corresponding index, otherwise throw a `KeyError`.
    get(model::ModelLike, ::Type{ConstraintIndex{F,S}}, name::String) where {F<:AbstractFunction,S<:AbstractSet}
If an `F`-in-`S` constraint with name `name` exists in the model `model`, return the corresponding index, otherwise throw a `KeyError`.
    get(model::ModelLike, ::Type{ConstraintIndex}, name::String)
If *any* constraint with name `name` exists in the model `model`, return the corresponding index, otherwise throw a `KeyError`. This version is available for convenience but may incur a performance penalty because it is not type stable.
### Examples
```julia
get(model, ObjectiveValue())
get(model, VariablePrimal(), ref)
get(model, VariablePrimal(5), [ref1, ref2])
get(model, OtherAttribute("something specific to cplex"))
get(model, VariableIndex, "var1")
get(model, ConstraintIndex{ScalarAffineFunction{Float64},LessThan{Float64}}, "con1")
get(model, ConstraintIndex, "con1")
```
"""
# TODO function MOI.get(optimizer::PisingerKnapsackOptimizer, attr::MOI.TerminationStatus)
#
# end
#
# TODO function MOI.get(optimizer::PisingerKnapsackOptimizer, attr::MOI.ObjectiveValue)
#
# end
#
# TODO function MOI.get(optimizer::PisingerKnapsackOptimizer, attr::MOI.VariablePrimal, id::MOI.VariableIndex)
#
# end
#
# TODO function MOI.get(optimizer::PisingerKnapsackOptimizer, attr::MOI.VariablePrimal, ids::Vector{JuMP.VariableRef})
#
# end

# Others functions to set the inner model
knpconstraintcounter(::PisingerKnapsackOptimizer, ::Type{<:MOI.AbstractFunction}, ::Type{<:MOI.AbstractSet}) = 0
knpconstraintcounter(::PisingerKnapsackOptimizer, ::Type{<:MOI.ScalarAffineFunction{Float64}}, ::Type{<:MOI.LessThan}) = 1

function getvarid(idxmap, moivarindex)
    return idxmap.varmap[moivarindex].value
end

function updateinnermodel!(optimizer::PisingerKnapsackOptimizer, src::MOI.ModelLike, idxmap, Func::Type{<:MOI.AbstractFunction}, Set::Type{<:MOI.AbstractSet})
    for ci in MOI.get(src, MOI.ListOfConstraintIndices{Func, Set}())
        f = MOI.get(src, MOI.ConstraintFunction(), ci)
        s = MOI.get(src, MOI.ConstraintSet(), ci)
        loadconstraint!(optimizer, ci, idxmap, f, s)
    end
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, ci, idxmap, f::MOI.SingleVariable, s::MOI.ZeroOne)
    # Nothing to do
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, ci, idxmap, f::MOI.SingleVariable, s::MOI.Integer)
    # Nothing to do
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, ci, idxmap, f::MOI.SingleVariable, s::MOI.GreaterThan)
    (s.lower != 0) && error("Variables lower bounds must be 0.")
    # Nothing more to do for now
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, ci, idxmap, f::MOI.SingleVariable, s::MOI.LessThan)
    ub = Integer(floor(s.upper))
    (s.upper > ub) && error("Upper bound of variables must be integer.")
    varid = getvarid(idxmap, f.variable)
    setitemub!(optimizer.inner_model, varid, ub)
end

function loadconstraint!(optimizer::PisingerKnapsackOptimizer, ci, idxmap, f::MOI.ScalarAffineFunction{Float64}, s::MOI.LessThan)
    for term in f.terms
        weight = Integer(floor(term.coefficient))
        (term.coefficient > weight) && error("Weight of items must be integer.")
        varid = getvarid(idxmap, term.variable_index)
        setweight!(optimizer.inner_model, varid, weight)
    end
    capacity = Integer(floor(s.upper))
    (s.upper > capacity) && error("Capacity of knapsack must be integer.")
    setcapacity!(optimizer.inner_model, capacity)
end

function additems!(optimizer::PisingerKnapsackOptimizer, idxmap, vis_src)
    for (i, vi) in enumerate(vis_src)
        varid = additem!(optimizer.inner_model)
        idxmap.varmap[vi] = MOI.VariableIndex(varid)
    end
end

function setprofits!(optimizer::PisingerKnapsackOptimizer, idxmap, f::MOI.ScalarAffineFunction)
    for term in f.terms
        varid = getvarid(idxmap, term.variable_index)
        setprofit!(optimizer.inner_model, varid, term.coefficient)
    end
end
