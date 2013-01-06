# this takes a DataFrame and returns the DataFrame with
# an additional column whose value is a simple moving average


function add_sma(df::DataFrame, n::Int64, col::ASCIIString)

  function sma(x,n)
    foo = [sum(x[i:i+(n-1)])/n for i=1:length(x)-(n-1)]
    bar = [nas(DataVector[float(n)], n-1) ; foo]
  end

  new_col = strcat("ma.", string(n))

  within!(df, quote
    $new_col  = $sma(vector($df[$col]), $n)
        end);
  df
end

