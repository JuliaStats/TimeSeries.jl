require("test.jl")

using Thyme

my_tests = ["test/returns.jl",
            "test/lead_lag.jl",
            "test/moving.jl",
            "test/upto.jl",
            "test/read_stock.jl"]

print_with_color(:cyan, "Running tests: ") 
println("")

for my_test in my_tests
    print_with_color(:magenta, "**   ") 
    print_with_color(:blue, "$my_test") 
    println("")
    include(my_test)
end
