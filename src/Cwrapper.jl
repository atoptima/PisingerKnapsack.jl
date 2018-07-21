module PisingerKnapsackCInterface

const Double = Float64

import ..PisingerKnapsack

export bouknap,
       dbouknap,
       minknap,
       dminknap

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
function bouknap(p::Vector{Cint}, w::Vector{Cint}, ub::Vector{Cint}, capacity::Integer)
    nbitems = length(p)
    solution = fill(Cint(0), nbitems)
    obj = @pk_bou_ccall bouknap Clong (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint},
            Ptr{Cint}, Cint) nbitems p w ub solution capacity
    return (obj, solution)
end

function bouknap(p::Vector{T}, w::Vector{T}, ub::Vector{T}, capacity::Integer) where T <: Integer
    #warn("minknap: using Int64 instead of Cint.")
    return bouknap(convert(Vector{Cint}, p), convert(Vector{Cint}, w), convert(Vector{Cint}, ub), capacity)
end

# libminknap functions
function minknap(p::Vector{Cint}, w::Vector{Cint}, capacity::Integer)
    nbitems = length(p)
    solution = fill(Cint(0), nbitems)
    obj = @pk_min_ccall minknap Clong (Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint},
            Cint) nbitems p w solution capacity
    return (obj, solution)
end

function minknap(p::Vector{T}, w::Vector{T}, capacity::Integer) where T <: Integer
    #warn("minknap: using Int64 instead of Cint.")
    return minknap(convert(Vector{Cint}, p), convert(Vector{Cint}, w), capacity)
end

end
