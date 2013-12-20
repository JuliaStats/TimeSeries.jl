module TestPercentChange

using Base.Test
using TimeSeries
using DataArrays

  df  = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))
  sr  = percentchange(df["Close"])
  lr  = percentchange(df["Close"], method="log")
  
  @assert isna(sr[1]) == true
  @assert sr[2]       == 0.004946236559139147    #  0.0049462366 in R quantmod::dailyReturn
  @assert sr[507]     == 0.0030457850265285026   #  0.003045785  in R quantmod::dailyReturn 
  
  @assert isna(lr[1]) == true
  @assert lr[2]       == 0.0049340441190235396   #  0.0049340441 in R quantmod::dailyReturn(type="log")
  @assert lr[507]     == 0.003041156020238134    #  0.003041156  in R quantmod::dailyReturn(type="log") 

  @test_throws 0.0 == percentchange(df["Close"], method="logarithmic")
end
