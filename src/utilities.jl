function overlaps(t1::Vector, t2::Vector)
    i = j = 1
    idx1 = Int[]
    idx2 = Int[]
    while i <= length(t1) && j <= length(t2)
        if t1[i] > t2[j]
            j += 1
        elseif t1[i] < t2[j]
            i += 1
        else
            push!(idx1, i)
            push!(idx2, j)
            i += 1
            j += 1
        end
    end
    (idx1, idx2)
end

noverlaps(ts::Vararg{Vector, 1}) = (Base.OneTo(length(ts[1])),)

function noverlaps(ts::Vararg{Vector, N}) where {N}
    iter = ones(Int, N)
    len = length.(ts)
    idx = ntuple(_ -> Int[], N)

    while all(iter .<= len)
        val = getindex.(ts, iter)  # get the timestamps values

        if length(unique(val)) == 1
            push!.(idx, iter)
            iter .+= 1
        else
            m = maximum(val)
            iter .+= (val .< m)
        end
    end

    idx
end

function sorted_unique_merge(a::Vector, b::Vector)

		i, na, j, nb = 1, length(a), 1, length(b)
		c = similar(a, 0)

		while (i <= na) && (j <= nb)
				if a[i] < b[j]
						push!(c, a[i])
						i += 1
				elseif a[i] > b[j]
						push!(c, b[j])
						j += 1
				else
						push!(c, a[i])
						i += 1
						j += 1
				end #if
		end

		append!(c, a[i:end])
		append!(c, b[j:end])

    return c

end  # sorted_unique_merge

function setcolnames!(ta::TimeArray, colnames::Vector)
    length(colnames) == length(ta.colnames) ? ta.colnames[:] = colnames :
    length(colnames) > 0 && error("colnames supplied is not correct size")
    return ta
end  # setcolnames!

