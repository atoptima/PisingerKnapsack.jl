module PisingerKnapsackCInterface

const Double = Float64

import ..PisingerKnapsack

export bouknap,
       minknap

# helper macros/functions
macro pk_min_ccall(func, args...)
    args = map(esc, args)
    f = "$func"
    quote
        ccall(($f, PisingerKnapsack._jl_libminknap), $(args...))
    end
end

macro pk_bou_ccall(func, args...)
    args = map(esc, args)
    f = "$func"
    quote
        ccall(($f, PisingerKnapsack._jl_libbouknap), $(args...))
    end
end

# libbouknap functions
function bouknap(p::Vector{Cint}, w::Vector{Cint}, ub::Vector{Cint}, capacity::Cint)
    nbitems = length(p)
    solution = fill(Cint(0), nbitems)
    obj = @pk_bou_ccall bouknap Clong (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint},
            Ptr{Cint}, Cint) nbitems p w ub solution capacity
    return (obj, solution)
end

function bouknap(p::Vector, w::Vector, ub::Vector, capacity)
    return bouknap(convert(Vector{Cint}, p), convert(Vector{Cint}, w), convert(Vector{Cint}, ub), Cint(capacity))
end

# libminknap functions
function minknap(p::Vector{Cint}, w::Vector{Cint}, capacity::Cint)
    nbitems = length(p)
    solution = fill(Cint(0), nbitems)
    obj = @pk_min_ccall minknap Clong (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint},
            Cint) nbitems p w solution capacity
    return (obj, solution)
end

function minknap(p::Vector, w::Vector, capacity)
    return minknap(convert(Vector{Cint}, p), convert(Vector{Cint}, w), Cint(capacity))
end

end
