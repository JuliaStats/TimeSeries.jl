# this takes a DataFrame and returns the DataFrame with
# an additional column whose value is defined a function


function add_mvg(df::DataFrame, col::ASCIIString, f, n::Int64)


  function mvg(x,f,n)
    foo = [f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
    bar = [nas(DataVector[float(n)], n-1) ; float(foo)]
  end

  new_col = strcat(string(f), "_", string(n))

  within!(df, quote
         $new_col  = $mvg($df[$col], $f, $n)
        end);
end

