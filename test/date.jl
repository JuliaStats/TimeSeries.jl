using Base.Test
using TimeSeries

let

  df = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))
  
  df_year   = byyear(df,1970)
  df_month  = bymonth(df,4)
  df_day    = byday(df,15)
  df_dow    = bydow(df,5)
  df_doy    = bydoy(df,2)
  df_to1    = to(df,1970,12,31) # includes row in series
  df_to2    = to(df,1971,1,1)
  df_from1  = from(df,1971,1,4) # includes row in series
  df_from2  = from(df,1971,1,1)
  df_btween = between(df,1970,1,5,1970,1,11) # to a date not in the df so last should be Jan 9th
  df_wkly   = collapse(df, ("Date", maximum), ("Open", first), ("High", maximum), ("Low", minimum), ("Close", last))
  df_mthly  = collapse(df, ("Date", maximum), ("Open", first), ("High", maximum), ("Low", minimum), ("Close", last), period=month)

  @assert 1970                == year(df_year[1,1]) 
  @assert 4                   == month(df_month[1,1]) 
  @assert 15                  == day(df_day[1,1]) 
  @assert 5                   == dayofweek(df_dow[1,1]) 
  @assert 2                   == dayofyear(df_dow[1,1]) 
  @assert date(1970, 12, 31)  == tail(df_to1, 1)[1,"Date"]
  @assert date(1970, 12, 31)  == tail(df_to2, 1)[1,"Date"]
  @assert date(1971, 1, 4)    == head(df_from1, 1)[1,"Date"]
  @assert date(1971, 1, 4)    == head(df_from2, 1)[1,"Date"]
  @assert date(1970, 1, 5)    == head(df_btween, 1)[1,"Date"]
  @assert date(1970, 1, 9)    == tail(df_btween, 1)[1,"Date"]
  @assert 5                   == size(df_btween, 1)
  @assert 93.00               == df_wkly[2, "Open"]
  @assert 94.25               == df_wkly[2, "High"]
  @assert 91.82               == df_wkly[2, "Low"]
  @assert 92.40               == df_wkly[2, "Close"]
  @assert 92.06               == df_mthly[1, "Open"]
  @assert 94.25               == df_mthly[1, "High"]
  @assert 84.42               == df_mthly[1, "Low"]
  @assert 85.02               == df_mthly[1, "Close"]

end
