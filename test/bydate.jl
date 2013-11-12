using Base.Test
using TimeSeries

let

  df = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))
  
  df_year  = byyear(df,1970)
  df_month = bymonth(df,4)
  df_day   = byday(df,15)
  df_dow   = bydow(df,5)
  df_doy   = bydoy(df,2)
  df_gt    = gtrows(df,12,30,1971)
  df_gte   = gterows(df,12,30,1971)
  df_lt    = ltrows(df,12,30,1971)
  df_lte   = lterows(df,12,30,1971)
  df_eq    = eqrows(df,12,13,1971)
  
  @assert 1970 == year(df_year[1,1]) 
  @assert 4    == month(df_month[1,1]) 
  @assert 15   == day(df_day[1,1]) 
  @assert 5    == dayofweek(df_dow[1,1]) 
  @assert 2    == dayofyear(df_dow[1,1]) 
  @assert 1    == nrow(df_gt)
  @assert 2    == nrow(df_gte)
  @assert 505  == nrow(df_lt)
  @assert 506  == nrow(df_lte)
  @assert 1    == nrow(df_eq)

end
