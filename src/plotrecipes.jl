
@recipe function f{T<:TimeArray}(ta::T)
    labels --> reshape(ta.colnames,1,length(ta.colnames))
    seriestype --> :path
    ta.timestamp, ta.values
end
