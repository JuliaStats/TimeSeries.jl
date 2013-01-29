######################## working #########

####### Array version

function moving{T<:Real}(v::Array{T}, f::Function, n::Integer)
  convert(Array{T}, [f(v[i:i+(n-1)]) for i=1:length(v)-(n-1)])
end

######### DataArray version

function moving(df::DataFrame, col::String, f::Function, n::Integer)
  with(df, quote
       $mvg($df[$col], $f, $n)
       end)
end

############ DataFrames bang version 

function mvg(dv::DataArray,f::Function,n::Integer)
  foo = [f(dv[i:i+(n-1)]) for i=1:length(dv)-(n-1)]
  bar = [nas(DataVector[float(n)], n-1) ; float(foo)]
end

function moving!(df::DataFrame, col::String, f::Function, n::Integer)
  new_col = strcat(string(f), "_", string(n))
  within!(df, quote
          $new_col  = $mvg($df[$col], $f, $n)
          end)
end

################## not working refactor attempts ###########

######### function moving(dv::DataArray, f::Function, n::Integer)
#########   padNA(f([dv[i:i+(n-1)] for i=1:length(dv)-(n-1)]), n-1, 0)
######### end

### function moving!(df::DataFrame, col::String, f::Function, n::Integer)
###   new_col = strcat(string(f), "_", string(n))
###   within!(df, quote
###            $new_col  = $moving($df[$col], $f, $n)
###            end)
### end
 
#################### exponential #################################

function sma(x,n)
  [mean(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function ema(dv::DataArray, n::Integer)
  k = 2/(n+1)
  m = sma(dv, n) 

  if n == 1
    [dv[i] = dv[i] for i=1:length(dv)]
  else
    dv[n] = m[1] 
    [dv[i] = dv[i]*k + dv[i-1]*(1-k) for i=(n+1):length(dv)]
  end
  dv[n:length(dv)]
end

