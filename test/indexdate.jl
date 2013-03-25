df = read_csv_for_testing(Pkg.dir("TimeSeries/test/data/spx.csv"))

df_year  = indexyear(df,1970)
df_month = indexmonth(df,4)
df_day   = indexday(df,15)
df_dow   = indexdow(df,2)

@assert 1970 == year(df_year[1,1]) 
@assert 4    == month(df_month[1,1]) 
@assert 15   == day(df_day[1,1]) 
@assert 2    == dayofweek(df_dow[1,1]) 
