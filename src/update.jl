###### update ####################

# function update{T,N,M,D}(ta::TimeArray{T,N,D}, timestamp{D}, values{T,N}
# julia> function update(ta::TimeArray, timestamp, values; colnames=ta.colnames, meta=ta.meta)
# TimeArray(timestamp, values, ta.colnames, ta.meta)
# end
# update (generic function with 3 methods)
# julia> function update(ta::TimeArray, colnames::Vector{UTF8String})
# TimeArray(ta.timestamp, ta.values, colnames, ta.meta)
# end
# update (generic function with 3 methods)
# julia> function update(ta::TimeArray, meta)
# TimeArray(ta.timestamp, ta.values, ta.colnames, meta)
# end
# update (generic function with 3 methods)
# julia> new_timestamp = cl.timestamp[2:end];kk
