#################################
# bydate ########################
#################################

for (byfun,calfun) = ((:byyear,:year), (:bymonth,:month), (:byday,:day), (:bydow,:dayofweek), (:bydoy,:dayofyear))
                      # (:byhour,:hour), (:byminute,:minute), (:bysecond,:second)
  @eval begin
    # get array of ints that correspon to dates and call getindex on that
    function ($byfun){T,N}(ta::TimeArray{T,N}, t::Int) 
      boolarray = [[$calfun(d.timestamp) for d in 1:length(ta.timestamp)] .== t]
      rownums = 
      ta[rownums]
    end # function
  end # eval
end # loop
 
#################################
# from, to ######################
#################################
 
function from{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[date(y,m,d):last(ta.timestamp)]
end 

function to{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[ta.timestamp[1]:date(y,m,d)]
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
