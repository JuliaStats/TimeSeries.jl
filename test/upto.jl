df = read_csv_for_testing(Pkg.dir("TimeSeries", "test", "data"), "spx.csv")

upto!(df, "Close", mean);
upto!(df, "Close", var);
#upto!(df, "Close", skewness);
#upto!(df, "Close", kurtosis);
upto!(df, "Close", min);
upto!(df, "Close", max);

@assert df[507,8]    == mean(df["Close"])
@assert df[507,9]    == var(df["Close"])
#@assert df[507,10]   == skewness(df["Close"])
#@assert df[507,11]   == kurtosis(df["Close"])
@assert df[507,10]   == min(df["Close"])
#@assert df[507,12]   == min(df["Close"])
#@assert df[507,13]   == max(df["Close"])
@assert df[507,11]   == max(df["Close"])
                                    
