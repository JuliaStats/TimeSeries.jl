overlap(ts::Vararg{Vector, 1}) = (Base.OneTo(length(ts[1])),)

function overlap(ts::Vararg{Vector, N}) where {N}
    ret = ntuple(_ -> Int[], N)
    t1 = ts[1]

    for tidx in 2:N
        i = j = 1
        resize!(ret[1], 0)
        t2 = ts[tidx]
        while i <= length(t1) && j <= length(t2)
            if t1[i] > t2[j]
                j += 1
            elseif t1[i] < t2[j]
                i += 1
            else
                push!(ret[1], i)
                push!(ret[tidx], j)
                i += 1
                j += 1
            end
        end
    end
    ret
end

"""
    sorted_unique_merge(a, b) -> (c, idx_a, idx_b)

Merge two arrays of sorted unique elements a and b to new array c,
and calculate the indexes idx_a and idx_b mapping each element in a and b to their new locations in c.
"""
function sorted_unique_merge(::Type{IndexType}, a::Vector, b::Vector) where {IndexType}
    i, na, j, nb = 1, length(a), 1, length(b)
    c = similar(a, length(a) + length(b))
    idx_a = Vector{IndexType}(undef, length(a))
    idx_b = Vector{IndexType}(undef, length(b))
    k = 1
    @inbounds while (i <= na) && (j <= nb)
        if a[i] < b[j]
            c[k] = a[i]
            idx_a[i] = k
            i += 1
        elseif a[i] > b[j]
            c[k] = b[j]
            idx_b[j] = k
            j += 1
        else
            c[k] = a[i]
            idx_a[i] = k
            idx_b[j] = k
            i += 1
            j += 1
        end
        k += 1
    end
    @inbounds while i <= na
        c[k] = a[i]
        idx_a[i] = k
        i += 1
        k += 1
    end
    @inbounds while j <= nb
        c[k] = b[j]
        idx_b[j] = k
        j += 1
        k += 1
    end
    resize!(c, k - 1)
    return c, idx_a, idx_b
end

"""
    insertbyidx!(dst, src, dstidx, coloffset = 0)

For each column in src, insert elements from src[i, column] to dst[dstidx[i], column + coloffset].
"""
function insertbyidx!(dst::AbstractArray, src::AbstractArray, dstidx::Vector, coloffset::Int = 0)
    for c in 1:size(src, 2)
        cc = c + coloffset
        for i in 1:length(dstidx)
            @inbounds dst[dstidx[i], cc] = src[i, c]
        end
    end
    nothing
end

"""
    insertbyidx!(dst, src, dstidx, srcidx)

For each column in src, insert elements from src[srcidx[i], column] to dst[dstidx[i], column].
"""
function insertbyidx!(dst::AbstractArray, src::AbstractArray, dstidx::Vector, srcidx::Vector)
    for c in 1:size(src, 2)
        for i in 1:length(srcidx)
            @inbounds dst[dstidx[i], c] = src[srcidx[i], c]
        end
    end
    nothing
end

@inline function allequal(x)
    length(x) < 2 && return true
    e1 = x[1]

    @inbounds for i ∈ 2:length(x)
        x[i] == e1 || return false
    end

    true
end

# helper method for inner constructor
@inline function _issorted_and_unique(x)
    for i in 1:length(x)-1
        @inbounds !(x[i] < x[i + 1]) && return false
    end
    true
end

# helper method for inner constructor
function replace_dupes!(cnames::Vector{Symbol})
    n = 1
    while !allunique(cnames)
        ds = find_dupes_index(cnames)
        for d in ds
            if n == 1
                cnames[d] = Symbol(cnames[d], "_$n")
            else
                s = string(cnames[d])
                cnames[d] = Symbol(s[1:length(s)-length(string(n))-1], "_$n")
            end
        end
        n += 1
    end
    cnames
end

# helper method for inner constructor
find_dupes_index(A::Vector{Symbol}) =
    @inbounds [i for i in eachindex(A) if A[i] ∈ A[1:i-1]]

gen_colnames(n::Integer) = gen_colnames(Val{n}())

@generated function gen_colnames(v::Val{N}) where {N}
    ret = Vector{Symbol}(undef, N)

    s = ""
    for i ∈ 1:N
        s = carry_char(s)
        ret[i] = Symbol(s)
    end

    ret
end

const carry_char_cache = Dict{String,String}("" => "A")

function carry_char(s::String = "")
    ret = get(carry_char_cache, s, "")
    (ret != "") && return ret

    n = length(s)

    c = s[n] + 1

    ret = if c > 'Z'
        c = 'A'
        carry_char(s[1:n-1]) * c
    else
        s[1:n-1] * c
    end

    carry_char_cache[s] = ret
end

# helper method for `getindex`
"""
Return the first index of the given column names.
Raise `KeyError` if col name not found.
"""
findcol(ta::AbstractTimeSeries, s::Symbol) = findcol(colnames(ta), s)

@inline function findcol(cols::Vector{Symbol}, s::Symbol)
    i = findfirst(isequal(s), cols)
    (i === nothing) && throw(KeyError(s))
    i
end
