using Base.Test
using TimeSeries

let

  df = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))
  
  upto!(df, "Close", mean);
  upto!(df, "Close", var);
  #upto!(df, "Close", skewness);
  #upto!(df, "Close", kurtosis);
  upto!(df, "Close", minimum);
  upto!(df, "Close", maximum);
  
  @assert df[507,8]    == mean(df["Close"])
  @assert df[507,9]    == var(df["Close"])
  #@assert df[507,10]   == skewness(df["Close"])
  #@assert df[507,11]   == kurtosis(df["Close"])
  @assert df[507,10]   == minimum(df["Close"])
  #@assert df[507,12]   == minimum(df["Close"])
  #@assert df[507,13]   == maximum(df["Close"])
  @assert df[507,11]   == maximum(df["Close"])

end
