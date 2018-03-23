overlaps(ts::Vararg{Vector, 1}) = (Base.OneTo(length(ts[1])),)


function overlaps(ts::Vararg{Vector, N}) where {N}
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

function sorted_unique_merge(a::Vector, b::Vector)
    i, na, j, nb = 1, length(a), 1, length(b)
    c = similar(a, length(a) + length(b))
    k = 1
    @inbounds while (i <= na) && (j <= nb)
		if a[i] < b[j]
            c[k] = a[i]
			i += 1
		elseif a[i] > b[j]
            c[k] = b[j]
			j += 1
		else
            c[k] = a[i]
			i += 1
			j += 1
		end
        k += 1
    end
    while i <= na
        @inbounds c[k] = a[i]
        i += 1
        k += 1
    end
    while j <= nb
        @inbounds c[k] = b[j]
        j += 1
        k += 1
    end
    resize!(c, k - 1)
    return c
end

"""
    sorted_subset_idx(superset, subset) -> indices

Get indices in superset for elements in subset.
"""
function sorted_subset_idx(superset, subset)
    subset_len = length(subset)
    result = Vector{Int32}(subset_len)
    new_i = 1
    for i in 1:length(superset)
        @inbounds if superset[i] == subset[new_i]
            result[new_i] = i
            new_i += 1
            if new_i > subset_len
                break
            end
        end
    end
    result
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


function setcolnames!(ta::TimeArray, colnames::Vector)
    length(colnames) == length(ta.colnames) ? ta.colnames[:] = colnames :
    length(colnames) > 0 && error("colnames supplied is not correct size")
    return ta
end  # setcolnames!
