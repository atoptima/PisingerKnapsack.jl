using PisingerKnapsack.PisingerKnapsackCInterface

const PKCI = PisingerKnapsackCInterface

export doubleminknap

function rfloor(val::Double)::Integer
    rf_val = Integer(floor(val + val * 1e-10 + 1e-6))
    if (rf_val < val - 1 + 1e-6)
        rf_val += 1
    end
    return rf_val
end

function scale_vector_of_double(v::Vector{Double})
    n = length(v)
    int_v = Vector{Integer}()
    max_val = maximum(v)
    scaling_factor = typemax(Cint) / (n + 1) / max_val
    for i in 1:n
        push!(int_v, rfloor(scaling_factor * v[i]))
    end
    return int_v
end

function doubleminknap(p::Vector{Double}, w::Vector{T}, capacity::Integer) where T <: Integer
    int_p = scale_vector_of_double(p)
    (obj, sol) = PKCI.minknap(int_p, w, capacity)
    real_obj = sum(sol[i] * p[i] for i in 1:length(sol))
    return (real_obj, sol)
end
