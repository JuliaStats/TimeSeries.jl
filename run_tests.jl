require("Thyme")
using Thyme

my_tests = ["test/returns.jl",
            "test/lead_lag.jl",
            "test/moving.jl",
            "test/read_stock.jl"]

println("\33[36mRunning tests: \033[0m")

for my_test in my_tests
    print("\33[35m** \033[0m ")
    print_with_color("$my_test", :blue) 
    println("")
#    println("\33[35m** \033[0m $(my_test)") 
#    println(" * $(my_test)")
    include(my_test)
end
