df = read_stock("test/data/spx.csv");

lead!(df, "Close", 1);
lead!(df, "Close", 3);
lead!(df, "Close", 506);
lag!(df, "Close", 1);
lag!(df, "Close", 3);
lag!(df, "Close", 506);

@assert df[1,8]    == 93.46
@assert df[1,9]    == 92.63
@assert df[1,10]   == 102.09
@assert df[507,11]   == 101.78
@assert df[507,12]   == 101.95
@assert df[507,13]   == 93.0
