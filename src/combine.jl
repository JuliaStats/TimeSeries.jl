import Base: merge

###### merge ####################

function merge{T,N,M,D}(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, ::Type{Val{:inner}};
														colnames::Vector=[])

    ta1.meta != ta2.meta && error("metadata doesn't match")

    idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
    vals = [ta1[idx1].values ta2[idx2].values]

    ta = TimeArray(ta1[idx1].timestamp, vals, [ta1.colnames; ta2.colnames], ta1.meta)
		setcolnames!(ta, colnames)
		return ta

end

function merge{T,N,M,D}(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, ::Type{Val{:left}};
														colnames::Vector=[])

    ta1.meta != ta2.meta && error("metadata doesn't match")

    new_idx2, old_idx2 = overlaps(ta1.timestamp, ta2.timestamp)

    right_vals = NaN * zeros(length(ta1), length(ta2.colnames))
    right_vals[new_idx2, :]  = ta2.values[old_idx2, :]

    ta = TimeArray(ta1.timestamp, [ta1.values right_vals], [ta1.colnames; ta2.colnames], ta1.meta)
		setcolnames!(ta, colnames)
		return ta

end

function merge{T,N,M,D}(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, ::Type{Val{:right}};
														colnames::Vector=[])

		ta = merge(ta2, ta1, Val{:left})

		ncol2 = length(ta2.colnames)
		vals = [ta.values[:, (ncol2+1):end] ta.values[:, 1:ncol2]]

		ta = TimeArray(ta.timestamp, vals, [ta1.colnames; ta2.colnames])
		setcolnames!(ta, colnames)
		return ta

end

function merge{T,N,M,D}(ta1::TimeArray{T,N,D}, ta2::TimeArray{T,M,D}, ::Type{Val{:outer}};
														colnames::Vector=[])

    ta1.meta != ta2.meta && error("metadata doesn't match")

		timestamps = sorted_unique_merge(ta1.timestamp, ta2.timestamp)

		ta = TimeArray(timestamps, zeros(length(timestamps), 0), UTF8String[])
		ta = merge(ta, ta1, Val{:left})
		ta = merge(ta, ta2, Val{:left})
		setcolnames!(ta, colnames)
		return ta

end

# Default to inner merge
merge(ta1::TimeArray, ta2::TimeArray; colnames::Vector=[]) =
		merge(ta1, ta2, Val{:inner}, colnames=colnames)


# collapse ######################

function collapse{T,N,D}(ta::TimeArray{T,N,D}, f::Function; period::Function=week)
  
    w = [period(ta.timestamp[t]) for t in 1:length(ta)] # get weekly id from entire array
    z = Int[]; j = 1
    for i=1:length(ta) - 1 # create unique period ID array
        if w[i] != w[i+1]
            push!(z, j)
            j = j+1
        else
            push!(z,j)
        end         
    end
    
    # account for last row
    w[length(ta)]  ==  w[length(ta)-1] ? # is the last row the same period as 2nd to last row?
    push!(z, z[length(z)]) :  
    push!(z, z[length(z)] + 1)  
   
    # pre-allocate timestamp and value arrays
    tstamps = Array{D}(maximum(z))
    vals    = zeros(maximum(z)) # number of unique periods
    #replace their values except for the last row 
    for i = 1:maximum(z)-1  # iterate over period ID groupings
        temp       = ta[findfirst(z .== i):findfirst(z .== i+1)-1] # period's worth that will be squished
        tstamps[i] = temp[length(temp)].timestamp[1]
        vals[i]    = f(temp.values)
    end
    # and once again account for the last temp that isn't looped on above
    lasttemp = ta[findfirst(z .== maximum(z)):length(ta)]
    lasttempindex = lasttemp[length(lasttemp)].timestamp
    lasttempvalue = f(ta.values)
    
    # complete the tstamp and vals arrays with the last value
    tstamps[length(tstamps)] = lasttempindex[1]
    vals[length(vals)]       = lasttempvalue

    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end
