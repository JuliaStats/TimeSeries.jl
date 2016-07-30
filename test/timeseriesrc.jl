# this line because the const objects are not being exported
include(joinpath(dirname(@__FILE__), "..", "src/.timeseriesrc.jl"))

facts("const values are set the package defaults") do

  context("SHOWINT") do
      @fact SHOWINT --> true
  end

  context("DECIMALS") do
      @fact DECIMALS --> 4
  end
end
