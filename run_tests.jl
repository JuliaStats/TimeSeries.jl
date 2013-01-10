require("Thyme")
using Thyme

my_tests = ["test/returns.jl",
            "test/lead_lag.jl",
            "test/moving.jl",
            "test/read_stock.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
