require("DataFrames")
require("Calendar")
require("UTF16")

using DataFrames
using Calendar
using UTF16


df = read_stock("spx.csv")

@assert typeof(df[1])           == DataVec{CalendarTime}
@assert df[nrow(df),7]          == 102.09
@assert df[507,7]               == 102.09
##@assert df[nrow(df),1] - df[1,1] == 728 FixedCalendarDuration




