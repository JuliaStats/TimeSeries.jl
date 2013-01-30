df = read_yahoo(Pkg.dir("Thyme", "test", "data"), "spx.csv")

sr = simple_return(df["Close"])
lr = log_return(df["Close"])
ec = equity(df["Close"])

@assert sr[1]    == 0.0
@assert sr[2]    == 0.004946236559139147    #  0.0049462366 in R quantmod::dailyReturn
@assert sr[507]  == 0.0030457850265285026   #  0.003045785  in R quantmod::dailyReturn 

@assert lr[1]    == 0.0
@assert lr[2]    == 0.0049340441190235396   #  0.0049340441 in R quantmod::dailyReturn(type="log")
@assert lr[507]  == 0.003041156020238134    #  0.003041156  in R quantmod::dailyReturn(type="log") 

# @assert ec[1]    == NA
@assert ec[2]    == 1.004946236559139       #  0.00494623 in R PerformanceAnalytics::Return.cumulative
@assert ec[507]  == 1.097741935483871       #  0.09774194 in R PerformanceAnalytics::Return.cumulative
