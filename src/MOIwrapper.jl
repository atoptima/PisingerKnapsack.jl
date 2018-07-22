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
