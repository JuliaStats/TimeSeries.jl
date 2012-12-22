require("DataFrames")
require("Calendar")
require("UTF16")
require("../src/load_local.jl")

using DataFrames
using Calendar
using UTF16

test_group("Last row is consistent")

df1 =load_local("data/spx.csv")

