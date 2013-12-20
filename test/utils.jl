module TestUtils

using Base.Test
using DataArrays
using TimeSeries

  # pad test
	dvNA    = DataArray([1, 2, 3, 4])
	dvInt   = DataArray([1, 2, 3, 4])
	dvFloat = DataArray([1., 2, 3, 4])
	dvMix   = DataArray([1., 2, 3, 4])

  pad(dvNA, 2, 2, NA)
  pad(dvInt, 2, 2, 1) 
  pad(dvFloat, 2, 2, 1.) #first with a Float
  pad(dvMix, 2, 2, 1) #then with an Int (where you really need a Float)

  #dvNA
	@assert length(dvNA) == 8
	@assert sum(removeNA(dvNA)) == 10
  @assert sum(replaceNA(dvNA, 1)) == 14

  #dvInt
	@assert length(dvInt) == 8
	@assert sum(dvInt) == 14

  #dvFloat
	@assert length(dvFloat) == 8
	@assert sum(dvFloat) == 14

  #dvMix
	@assert length(dvMix) == 8
	@assert sum(dvMix) == 14
end
