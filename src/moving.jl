# moving returns only the padded result
# moving! modifies the DataFrame in place

function mvg(x,f,n)
  foo = [f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
  bar = [nas(DataVector[float(n)], n-1) ; float(foo)]
end

function moving(df::DataFrame, col::ASCIIString, f, n::Int64)
  with(df, quote
       $mvg($df[$col], $f, $n)
       end);
end

function moving!(df::DataFrame, col::ASCIIString, f, n::Int64)
  new_col = strcat(string(f), "_", string(n))
  within!(df, quote
         $new_col  = $mvg($df[$col], $f, $n)
        end);
end

########### EMA version ############################


## first attempt  ###########
## bad on many levels
## the last few entries appear accurate though it takes
## a while to stabilize

function sma(x,n)
  [mean(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function ema(dv::DataArray, n:int64)
  k = 2/(n+1)

  m = sma(x, n) 

  if n == 1
    [x[i] = x[i] for i=1:length(x)]
  else
    x[n-1] = m[1] 
    [x[i] = x[i]*k + [i-1]*(1-k) for i=n:length(x)]
  end
end



