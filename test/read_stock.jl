df = read_stock("test/data/spx.csv");

# @assert typeof(df[1])           == DataArray{CalendarTime,1}
@assert df[1,2]    == 92.06
@assert df[1,3]    == 93.54
@assert df[1,4]    == 91.79
@assert df[1,5]    == 93.0
@assert df[1,6]    == 8050000
@assert df[1,7]    == 93.0
@assert df[507,2]  == 102.09
@assert df[507,3]  == 102.09
@assert df[507,4]  == 102.09
@assert df[507,5]  == 102.09
@assert df[507,6]  == 14040000
@assert df[507,7]  == 102.09
