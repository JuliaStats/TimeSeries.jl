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

@generated function noverlaps(ts::Vararg{Vector, N}) where {N}
    idx = Expr(:tuple, map(i -> :(similar(ts[$i], Int)), 1:N)...)
    val = Expr(:vect, map(i -> :(ts[$i][iter[$i]]), 1:N)...)
    iter = Expr(:vect, ones(Int, N)...)
    len = Expr(:vect, map(i -> :(length(ts[$i])), 1:N)...)
    resize_exprs = Expr(:block, map(i -> :(resize!(idx[$i], j - 1)), 1:N)...)

    cond = :(iter[1] <= len[1])
    val_comp = Expr(:comparison, :(val[1]))
    for i ∈ 2:N
        cond = :($cond && iter[$i] <= len[$i])
        push!(val_comp.args, :(==), :(val[$i]))
    end

    quote
        iter = $iter
        len = $len
        idx = $idx
        j = 1

        while $cond
            val = $val

            if $val_comp
                for i ∈ 1:$N
                    idx[i][j] = iter[i]
                    iter[i] += 1
                end
                j += 1
            else
                m = maximum(val)
                for i ∈ 1:$N
                    if val[i] < m
                        iter[i] += 1
                    end
                end
            end
        end

        $resize_exprs
        idx
    end
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

