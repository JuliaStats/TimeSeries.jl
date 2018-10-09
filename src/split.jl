# when ############################

when(ta::TimeArray, period::Function, t::Integer) =
    ta[findall(period.(timestamp(ta)) .== t)]
when(ta::TimeArray, period::Function, t::String) =
    ta[findall(period.(timestamp(ta)) .== t)]

# from, to ######################

from(ta::TimeArray{T, N, D}, d::D) where {T, N, D} =
    length(ta) == 0 ? ta :
        d < timestamp(ta)[1] ? ta :
        d > timestamp(ta)[end] ? ta[1:0] :
        ta[searchsortedfirst(timestamp(ta), d):end]

to(ta::TimeArray{T, N, D}, d::D) where {T, N, D} =
    length(ta) == 0 ? ta :
        d < timestamp(ta)[1] ? ta[1:0] :
        d > timestamp(ta)[end] ? ta :
        ta[1:searchsortedlast(timestamp(ta), d)]

###### findall ##################

Base.findall(ta::TimeArray{Bool,1}) = findall(values(ta))

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = timestamp(ta)[findall(values(ta))]

###### head, tail ###########

@generated function head(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[1:n]) : :(values(ta)[1:n, :])

    quote
        new_timestamp = timestamp(ta)[1:n]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

 @generated function tail(ta::TimeArray{T,N}, n::Int=6) where {T,N}
    new_values = (N == 1) ? :(values(ta)[start:end]) : :(values(ta)[start:end, :])

    quote
        start = length(ta) - n + 1
        new_timestamp = timestamp(ta)[start:end]
        TimeArray(new_timestamp, $new_values, colnames(ta), meta(ta))
    end
end

###### first, last ###########

Base.first(ta::TimeArray) = head(ta, 1)

Base.last(ta::TimeArray) = tail(ta, 1)
