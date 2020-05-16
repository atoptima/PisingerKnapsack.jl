# libminknap methods
macro pk_min_ccall(func, args...)
    args = map(esc, args)
    f = "$func"
    quote
        ccall(($f, PisingerKnapsack._jl_libminknap), $(args...))
    end
end

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

# libbouknap methods
macro pk_bou_ccall(func, args...)
    args = map(esc, args)
    f = "$func"
    quote
        ccall(($f, PisingerKnapsack._jl_libbouknap), $(args...))
    end
end

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

# FYI : mcknap function generates random instances so we cannot use as provided by Pisinger

# macro pk_minmc_ccall(func, args...)
#     args = map(esc, args)
#     f = "$func"
#     quote
#         ccall(($f, PisingerKnapsack._jl_libminmcknap), $(args...))
#     end
# end

# libminmcknap functions
# function minmcknap(p::Vector{Cint}, w::Vector{Cint}, capacity::Cint, items_per_class::Vector{Cint})
#     nbitems = length(p)
#     nbclasses = length(items_per_class)
#     solution = fill(Cint(0), nbitems)
#     obj = @pk_minmc_ccall minmcknap Clong (Cint, Cint, Ptr{Cint}, Ptr{Cint}, 
#         Ptr{Cint}, Ptr{Cint}, Cint) nbitems nbclasses items_per_class p w solution capacity
#     return (obj, solution)
# end

# function minmcknap(p::Vector, w::Vector, capacity, items_per_class::Vector)
#     return minmcknap(convert(Vector{Cint}, p), convert(Vector{Cint}, w), Cint(capacity), convert(Vector{Cint}, items_per_class))
# end