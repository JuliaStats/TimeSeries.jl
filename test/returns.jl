
df = read_stock("test/data/spx.csv");
sr = simple_return(df["Close"])
lr = log_return(df["Close"])
ec = equity(df["Close"])


@assert sr[1]    == 0.0
@assert sr[2]    == 0.004946236559139147    # from R 0.0049462366    
@assert sr[507]  == 0.0030457850265285026   # from R 0.003045785    

@assert lr[1]    == 0.0
@assert lr[2]    == 0.0049340441190235396   # from R 0.0049340441  
@assert lr[507]  == 0.003041156020238134    # from R 0.003041156

# @assert ec[1]    == NA
@assert ec[2]    == 1.004946236559139       # from R 1.00494623
@assert ec[507]  == 1.097741935483871       # from R 1.09774194 
