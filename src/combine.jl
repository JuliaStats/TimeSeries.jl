#################################
###### merge ####################
#################################

#function merge{T,N}(ta1::TimeArray{T,N}, ta2::TimeArray{T,N}; method="inner")
function merge{T}(ta1::TimeArray{T}, ta2::TimeArray{T}; method="inner")
    tstamp = [date(1,1,1):years(1):date(length(ta1),1,1)]
    n      = 1
      for i in 1:length(ta1)
        for j in 1:length(ta2)
          if ta1.timestamp[i] == ta2.timestamp[j]
            tstamp[n] = ta1.timestamp[i]
            n+=1
          end
        end
      end
    tstamp = tstamp[1:n-1] # trim down the length, if necessary

    val1 = ta1[tstamp].values
    val2 = ta2[tstamp].values
    vals = hcat(val1, val2)

    cnames = copy(ta1.colnames) # otherwise ta1 gets contaminated
    for m in 1:length(ta2.colnames)
      push!(cnames, ta2.colnames[m])
    end

    TimeArray(tstamp, vals, cnames)
end

#################################
# collapse ######################
#################################

function collapse{T,N}(ta::TimeArray{T,N}, f::Function; period=week)
  
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
  tstamps = [date(1,1,1):years(1):date(maximum(z),1,1)]
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

  TimeArray(tstamps, vals, ta.colnames)
end
