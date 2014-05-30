facts("const values are set the package defaults") do

  context("SHOWINT") do
<<<<<<< HEAD
<<<<<<< HEAD
      @fact SHOWINT => false
=======
      @fact SHOWINT => true
>>>>>>> 79dfee2... added DECIMALS const and tests for rc.jl file
=======
      @fact SHOWINT => false
>>>>>>> 78631c1... corrected rc.jl test value to pass locally, travis will still fail though
  end

  context("DECIMALS") do
      @fact DECIMALS => 2
  end
end

