######## Array ############################

v      = rand(100)
vead   = lead(v, 1)
w      = rand(100)
wag    = lag(w, 1)

@assert v[2] == vead[1]
@assert 99 == length(vead)

@assert w[1] == wag[1]
@assert 99 == length(wag)

######## DataArray ######################

df = read_stock(Pkg.dir("Thyme", "test", "data", "spx.csv"))

lead!(df, "Close", 1)
lead!(df, "Close", 3)
lead!(df, "Close", 506)
lag!(df, "Close", 1)
lag!(df, "Close", 3)
lag!(df, "Close", 506)

@assert df[1,8]    == 93.46
@assert df[1,9]    == 92.63
@assert df[1,10]   == 102.09
@assert df[507,11]   == 101.78
@assert df[507,12]   == 101.95
@assert df[507,13]   == 93.0

