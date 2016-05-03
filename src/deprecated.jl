import Base.values

# deprecated by() ############################

function by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) 
    warn("by(ta::TimeArray, t::Int; period::Function) is being deprecated.\nPlease use when(ta::TimeArray, period::Function, t::Int)")
    boolarray = [[period(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t;] # odd syntax for t; but just t deprecated
    rownums = round(Int64, zeros(sum(boolarray)))
    j = 1
    for i in 1:length(boolarray)
        if boolarray[i]
            rownums[j] = i
            j+=1
        end
    end
    ta[rownums]
end 
 
function by{T,N}(ta::TimeArray{T,N}, t::ASCIIString; period::Function=day) 
    warn("by(ta::TimeArray, t::ASCIIString; period::Function) is being deprecated.\nPlease use when(ta::TimeArray, period::Function, t::ASCIIString)")
    boolarray = [[period(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t;] # odd syntax for t; but just t deprecated
    rownums = round(Int64, zeros(sum(boolarray)))
    j = 1
    for i in 1:length(boolarray)
        if boolarray[i]
            rownums[j] = i
            j+=1
        end
    end
    ta[rownums]
end 

# deprecated to / from methods

function to(ta::TimeArray, y::Int, m::Int, d::Int)
    warn("to(ta::TimeArray, y::Int, m::Int, d::Int) is being deprecated.\nPlease use to(ta::TimeArray, d::TimeType) instead")
    return to(ta, Date(y,m,d))
end #to

function from(ta::TimeArray, y::Int, m::Int, d::Int)
    warn("from(ta::TimeArray, y::Int, m::Int, d::Int) is being deprecated.\nPlease use from(ta::TimeArray, d::TimeType) instead")
    return from(ta, Date(y,m,d))
end #from

function findall(ta::TimeArray)
    warn("findall is deprecated, use find instead")
    return find(ta)
end #findall

function collapse{T,N,D}(ta::TimeArray{T,N,D}, f::Function; period::Function=week)

    warn("collapse(ta::TimeArray, f::Function; period::Function=week) is deprecated,\nuse collapse(ta::TimeArray, period::Function, timestamp::Function, value::Function=timestamp) instead")
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

