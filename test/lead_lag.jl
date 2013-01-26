######## Array ############################

v      = [1,2,3,4,5]
vlead  = lead(v)
vlag   = lag(v)

@assert [2,3,4,5] == vlead 
@assert [1,2,3,4] == vlag 

@assert 4 == length(vlead)
@assert 4 == length(vlag)

######## DataArray ######################

dv = DataArray([1,2,3,4,5]) 

dvlead  = lead(dv ,2)
dvlag   = lag(dv ,2)

#@assert [3,4,5,NA,NA] == dvlead 
#@assert [NA,NA,1,2,3] == dvlag 

@assert 5 == length(dvlead)
@assert 5 == length(dvlag)

######## DataFrame ######################

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

