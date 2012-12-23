require("DataFrames")
require("Calendar")
require("UTF16")

using DataFrames
using Calendar
using UTF16


df1 = read_stock("spx.csv")

@assert typeof(df1[1])           == DataVec{CalendarTime}
@assert df1[nrow(df),7]          == 102.09
@assert df1[507,7]               == 102.09
##@assert df[nrow(df),1] - df[1,1] == 728 FixedCalendarDuration




