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

