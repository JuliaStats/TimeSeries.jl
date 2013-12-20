using Base.Test
using TimeSeries

my_tests = ["date.jl",
            "io.jl",
            "lag.jl",
            "moving.jl",
            "percentchange.jl",
            "upto.jl",
            "utils.jl"]

print_with_color(:cyan, "Running tests: ") 
println("")

for my_test in my_tests
    print_with_color(:magenta, "**   ") 
    print_with_color(:blue, "$my_test") 
    println("")
    include(my_test)
end
