# this line because the const objects are not being exported
include(joinpath(dirname(@__FILE__), "..", "src/.timeseriesrc.jl"))

facts("const values are set the package defaults") do

  context("SHOWINT") do
      @fact SHOWINT --> true
  end

  context("DECIMALS") do
      @fact DECIMALS --> 4
  end

  context("MISSING") do
      @fact MISSING --> NAN
  end
end

facts("const values are correct") do

  context("NAN") do
      @fact NAN --> "NaN"
  end

  context("NA") do
      @fact NA --> "NA"
  end

  context("BLACKHOLE") do
      @fact BLACKHOLE --> "\u2B24"
  end

  context("DOTCIRCLE") do
      @fact DOTCIRCLE --> "\u25CC"
  end

  context("QUESTION") do
      @fact QUESTION --> "\u003F"
  end
end
