# moving is a simple moving window that weighs all elements equally

function moving(dv::DataArray,f::Function,n::Integer)
  padNA(DataArray([f(dv[i:i+(n-1)]) for i=1:length(dv)-(n-1)]), n-1, 0)
end

function moving(v::Array, f::Function, n::Integer)
  [f(v[i:i+(n-1)]) for i=1:length(v)-(n-1)]
end

function mvg(x::DataArray,f::Function,n::Integer)
  padNA(DataArray([f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]), n-1, 0)
end

function moving!(df::DataFrame, col::ASCIIString, f::Function, n::Integer)
  new_col = strcat(string(f), "_", string(n))
  within!(df, quote
           $new_col  = $mvg($df[$col], $f, $n)
           end)
end
#          function moving!(df::DataFrame, col::String, f::Function, n::Integer)
#            new_col = strcat(string(f), "_", string(n))
#            within!(df, quote
#                   $new_col  = $mvg($df[$col], $f, $n)
#                  end);
#          end
 
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

