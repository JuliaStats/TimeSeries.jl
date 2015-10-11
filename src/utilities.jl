function overlaps(t1, t2)
    i = j = 1
    idx1 = Int[]
    idx2 = Int[]
    while i < length(t1) + 1 && j < length(t2) + 1
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
