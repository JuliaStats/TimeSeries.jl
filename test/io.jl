module TestIO

using Base.Test
using TimeSeries
using Datetime
  
  df = readtime(Pkg.dir("TimeSeries/test/data/readtimetest.csv"))
  
 # columns correctly parsed on type
  @assert typeof(df[1,1])  == Date{ISOCalendar}
  @assert typeof(df[1,2])  == UTF8String
  @assert typeof(df[1,3])  == Float64
  @assert typeof(df[1,4])  == Int64
 # IndexedVector 
 # TODO need correct assertion
#  @assert typeof(df[:,1])  == IndexedVector{Date{C<:Calendar},DataArray{Date{C<:Calendar},1}}
#  @assert df[:,1] <: IndexedVector{Date{C<:Calendar},DataArray{Date{C<:Calendar},1}}
 # descending order 
  @assert df[1,1]   <  df[2,1]
end
  
