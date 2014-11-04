# this line because the const objects are not being exported
include(Pkg.dir("TimeSeries/src/.timeseriesrc.jl"))

facts("const values are set the package defaults") do

  context("SHOWINT") do
      @fact SHOWINT => false
  end

  context("DECIMALS") do
      @fact DECIMALS => 2
  end
end
