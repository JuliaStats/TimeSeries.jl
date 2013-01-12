# moving is a simple moving window that weights all elements equally
# moving returns only the padded result
# moving! modifies the DataFrame in place

function mvg(x::DataArray,f::Function,n::Int64)
  foo = [f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
  bar = [nas(DataVector[float(n)], n-1) ; float(foo)]
end

function moving(df::DataFrame, col::ASCIIString, f::Function, n::Int64)
  with(df, quote
       $mvg($df[$col], $f, $n)
       end);
end

function moving!(df::DataFrame, col::ASCIIString, f::Function, n::Int64)
  new_col = strcat(string(f), "_", string(n))
  within!(df, quote
         $new_col  = $mvg($df[$col], $f, $n)
        end);
end
 
#################### exponential #################################

function sma(x,n)
  [mean(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function ema(dv::DataArray, n::Int64)
  k = 2/(n+1)
  m = sma(dv, n) 

  if n == 1
    [dv[i] = dv[i] for i=1:length(dv)]
  else
    dv[n-1] = m[1] 
  [dv[i] = dv[i]*k + dv[i-1]*(1-k) for i=n:length(dv)]
  end
end

