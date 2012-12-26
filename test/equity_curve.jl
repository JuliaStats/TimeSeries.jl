require("DataFrames")
require("Calendar")
require("UTF16")

using DataFrames
using Calendar
using UTF16

macro taste(food)
 :($food ? 
 print("\33[32mfresh\033[0m ")  :
 print("\33[31mrotten\033[0m "))
end

df = read_stock("spx.csv")
ec = equity_curve(df)

@taste ec[1]    == 1.0
@taste ec[2]    == 1.0049340441190235
@taste ec[507]  == 1.0932552840276681



