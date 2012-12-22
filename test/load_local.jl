require("DataFrames")
require("Calendar")
require("UTF16")
#require("../src/load_local.jl")

using DataFrames
using Calendar
using UTF16


function load_local(x)
 time_based_df = read_table(x);
# foo = convert(Array{UTF16String}, time_based_df[:,1])
 bar = map(x -> parse("yyyy-MM-dd", x), convert(Array{UTF16String}, vector(time_based_df[:,1])))
 within!(time_based_df, quote
         Date = $(bar)
         end);
flipud(time_based_df)
end

#test_group("Last row is consistent")

df1 = load_local("data/spx.csv")

