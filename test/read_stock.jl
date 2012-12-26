require("DataFrames")
require("Calendar")
require("UTF16")

using DataFrames
using Calendar
using UTF16

macro taste(food)
 :($food ? 
 println("\33[32mfresh\033[0m ")  :
 println("\33[31mrotten \033[0m", "\33[36mho\033[0m"))
end

df = read_stock("spx.csv")

@taste typeof(df[1])           == DataVec{CalendarTime}
@taste df[nrow(df),7]          == 102.09
@taste df[507,7]               == 102.09
@taste df[507,7]               == 102.0
@taste df[507,7]               == 102.09




# @taste df[nrow(df),1] - df[1,1] == 728 FixedCalendarDuration




