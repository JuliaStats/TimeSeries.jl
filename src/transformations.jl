#################################
###### lag, lead ################
#################################
  
function lag{T,N}(ta::TimeArray{T,N}; period::Int=1) 
  TimeArray(ta.timestamp[period+1:end], ta.values[1:length(ta)-period], ta.colnames)
end

function lag{T,N}(ta::TimeArray{T,N}, n::Int) 
  TimeArray(ta.timestamp[n+1:end], ta.values[1:length(ta)-n], ta.colnames)
end

function lead{T,N}(ta::TimeArray{T,N}; period::Int=1) 
  TimeArray(ta.timestamp[1:length(ta)-period], ta.values[period+1:end], ta.colnames)
end

function lead{T,N}(ta::TimeArray{T,N}, n::Int) 
  TimeArray(ta.timestamp[1:length(ta)-n], ta.values[n+1:end], ta.colnames)
end

#################################
###### percentchange ############
#################################

function percentchange{T,N}(ta::TimeArray{T,N}; method="simple") 
  logreturn = log(ta.values)[2:end] .- log(lag(ta).values)

  if method == "simple" 
    TimeArray(ta.timestamp[2:end], expm1(logreturn), ta.colnames) 
  elseif method == "log" 
    TimeArray(ta.timestamp[2:end], logreturn, ta.colnames) 
  else msg("only simple and log methods supported")
  end
end

#################################
###### moving ###################
#################################

function moving{T,N}(ta::TimeArray{T,N}, f::Function, n::Int) 
  
end

#################################
###### upto #####################
#################################

function upto{T,N}(ta::TimeArray{T,N}, f::Function) 
end
