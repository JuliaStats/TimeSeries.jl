using Base.Test
using TimeSeries

let

  df = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))
  
  df_year  = byyear(df,1970)
  df_month = bymonth(df,4)
  df_day   = byday(df,15)
  df_dow   = bydow(df,5)
  df_doy   = bydoy(df,2)

# need from, to, between and toweekly tests
  
  @assert 1970 == year(df_year[1,1]) 
  @assert 4    == month(df_month[1,1]) 
  @assert 15   == day(df_day[1,1]) 
  @assert 5    == dayofweek(df_dow[1,1]) 
  @assert 2    == dayofyear(df_dow[1,1]) 

end
