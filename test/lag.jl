####### Array ############################

vi      = [1,2,3,4,5]
vf      = [1.,2,3,4,5]
vb      = [true, true, false, false, false]
vs      = ["a", "b", "c", "d", "e"]

vi_lead   = lead(vi)
vf_lead   = lead(vf, 2)
vb_lead   = lead(vb, 3)
vs_lead   = lead(vs, 4)

vi_lag   = lag(vi)
vf_lag   = lag(vf, 2)
vb_lag   = lag(vb, 3)
vs_lag   = lag(vs, 4)

@assert [2,3,4,5]      == vi_lead 
@assert [3.0,4.0,5.0]  == vf_lead
@assert [false, false] == vb_lead
@assert ["e"]          == vs_lead

@assert [1,2,3,4]       == vi_lag
@assert [1.0, 2.0, 3.0] == vf_lag
@assert [true, true]    == vb_lag
@assert ["a"]           == vs_lag


@assert 4 == length(vi_lead)
@assert 3 == length(vf_lead)
@assert 2 == length(vb_lead)
@assert 1 == length(vs_lead)

@assert 4 == length(vi_lag)
@assert 3 == length(vf_lag)
@assert 2 == length(vb_lag)
@assert 1 == length(vs_lag)

@assert lag(vi, -1) == lead(vi)

######## DataArray ######################

dvi = DataArray([1,2,3,4,5]) 
dvf = DataArray([1.,2,3,4,5]) 
dvb = DataArray([true, true, true, true, false]) 
dvs = DataArray(["a", "b", "c", "d", "e"]) 

dvi_lead  = lead(dvi)
dvf_lead  = lead(dvf,2)
dvb_lead  = lead(dvb,3)
dvs_lead  = lead(dvs,4)

dvi_lag = lag(dvi)
dvf_lag = lag(dvf,2)
dvb_lag = lag(dvb,3)
dvs_lag = lag(dvs,4)

@assert 5 == length(dvi_lead)
@assert 5 == length(dvf_lead)
@assert 5 == length(dvb_lead)
@assert 5 == length(dvs_lead)

@assert 5 == length(dvi_lag)
@assert 5 == length(dvf_lag)
@assert 5 == length(dvb_lag)
@assert 5 == length(dvs_lag)

@assert (lag(dvi, -1) .== lead(dvi))[1] == true

######## DataFrame ######################

df = read_csv_for_testing(Pkg.dir("TimeSeries", "test", "data"), "spx.csv")

lead!(df, "Close", 1)
lead!(df, "Close", 3)
lead!(df, "Close", 506)
lag!(df, "Close", 1)
lag!(df, "Close", 3)
lag!(df, "Close", 506)

@assert df[1,8]      == 93.46
@assert df[1,9]      == 92.63
@assert df[1,10]     == 102.09
@assert df[507,11]   == 101.78
@assert df[507,12]   == 101.95
@assert df[507,13]   == 93.0

