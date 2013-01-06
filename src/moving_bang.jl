# this takes a DataFrame and modifies it with a new
# column whose value is defined by a function


function moving!(df::DataFrame, col::ASCIIString, f, n::Int64)


  function mvg(x,f,n)
    foo = [f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
    bar = [nas(DataVector[float(n)], n-1) ; float(foo)]
  end

  new_col = strcat(string(f), "_", string(n))

  within!(df, quote
         $new_col  = $mvg($df[$col], $f, $n)
        end);
end

