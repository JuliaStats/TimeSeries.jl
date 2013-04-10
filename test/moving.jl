######## Array ############################

vi      = [1,2,3,4,5]
vf      = [1.,2,3,4,5]

#   vi_move   = moving(vi, sum, 2)
#   vf_move   = moving(vf, sum, 3)
#   
#   vi_move   = lag(vi)
#   vf_move   = lag(vf, 2)
#   
#   @assert [2,3,4,5]      == vi_move 
#   @assert [3.0,4.0,5.0]  == vf_move
#   
#   @assert [1,2,3,4]       == vi_move
#   @assert [1.0, 2.0, 3.0] == vf_move
#   
#   
#   @assert 4 == length(vi_move)
#   @assert 3 == length(vf_move)

######## DataArray ######################

# dvi = DataArray([1,2,3,4,5]) 
# dvf = DataArray([1.,2,3,4,5]) 
# dvb = DataArray([true, true, true, true, false]) 
# dvs = DataArray(["a", "b", "c", "d", "e"]) 
# 
# dvi_lead  = lead(dvi)
# dvf_lead  = lead(dvf,2)
# dvb_lead  = lead(dvb,3)
# dvs_lead  = lead(dvs,4)
# 
# dvi_lag = lag(dvi)
# dvf_lag = lag(dvf,2)
# dvb_lag = lag(dvb,3)
# dvs_lag = lag(dv,4)
# 
# @assert 5 == length(dvi_lead)
# @assert 5 == length(dvf_lead)
# @assert 5 == length(dvb_lead)
# @assert 5 == length(dvs_lead)
# 
# @assert 5 == length(dvi_lag)
# @assert 5 == length(dvf_lag)
# @assert 5 == length(dvb_lag)
# @assert 5 == length(dvs_lag)

######## DataFrame ######################
df = read_time(Pkg.dir("TimeSeries/test/data/spx.csv"))

moving!(df, "Close", mean, 50)
moving!(df, "Close", mean, 200)
moving!(df, "Close", var, 50)
moving!(df, "Close", skewness, 50)
moving!(df, "Close", kurtosis, 50)
moving!(df, "Close", min, 50)
moving!(df, "Close", max, 50)

@assert df[507,8]   == 95.8616             # 95.8616    in R's zoo::rollapply and mean
@assert df[507,9]   == 98.84799999999997   # 98.8480    in R's zoo::rollapply and mean
@assert df[507,10]  == 12.3920586122449    # 12.39206   in R's zoo::rollapply and var 
@assert df[507,11]  == 0.4210029720570054  # 0.421003   in R's zoo::rollapply and PerformanceAnalytics::skewness (pandas uses biased estimator and gets a different answer)
@assert df[507,12]  == -0.9264508782271186 # -0.9264509 in R's zoo::rollapply and PerformanceAnalytics::kurtosis (pandas uses biased estimator and gets a different answer)
@assert df[507,13]  == 90.16               # 90.16      in R's zoo::rollapply and min 
@assert df[507,14]  == 102.21              # 102.21     in R's zoo::rollapply and max 
                                    
# dv1 = df["Open"];
# dv2 = df["Close"];
# dv3 = df["Adj Close"];
# 
# e1  = ema(dv1,1)
# e2  = ema(dv2,2)
# e13 = ema(dv3,13)
# 
# @assert e1[507]  == dv1[507]
# @assert e2[506]  == 102.01237121462606  # R's TTR::EMA returns 102.01237 (rounded)
# @assert e13[495] == 100.62558587207887  # R's TTR::EMA returns 100.62559 (rounded)
                                    
