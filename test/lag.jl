module TestLag

using Base.Test
using DataArrays
using DataFrames
using TimeSeries

  df = readtime(Pkg.dir("TimeSeries/test/data/spx.csv"))

######## DataArray ######################
  
  dvi = DataArray([1,2,3,4,5]) 
  dvf = DataArray([1.,2,3,4,5]) 
  dvb = DataArray([true, true, true, true, false]) 
  dvs = DataArray(["a", "b", "c", "d", "e"]) 
  
  dvi_lead  = lead(dvi)
  dvf_lead  = lead(dvf,2)
  dvb_lead  = lead(dvb,3)
  # dvs_lead  = lead(dvs,4)
   
  dvi_lag = lag(dvi)
  dvf_lag = lag(dvf,2)
  dvb_lag = lag(dvb,3)
  # dvs_lag = lag(dvs,4)
   
  # @assert 5 == length(dvi_lead)
  # @assert 5 == length(dvf_lead)
  # @assert 5 == length(dvb_lead)
  # @assert 5 == length(dvs_lead)
  # 
  # @assert 5 == length(dvi_lag)
  # @assert 5 == length(dvf_lag)
  # @assert 5 == length(dvb_lag)
  # @assert 5 == length(dvs_lag)
  # 
  # @assert (lag(dvi, -1) .== lead(dvi))[1] == true
  # 
######## DataFrame ######################
  
  lead!(df, "Close", 1)
  lead!(df, "Close", 3)
  lead!(df, "Close", 506)
  lag!(df, "Close", 1)
  lag!(df, "Close", 3)
  lag!(df, "Close", 506)
  
  @assert df[1,8]      == 93.46
  @assert df[1,9]      == 92.63
  @assert df[1,10]     == 102.09
  @assert df[507,11]   == 101.78
  @assert df[507,12]   == 101.95
  @assert df[507,13]   == 93.0
end
