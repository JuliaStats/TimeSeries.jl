require("DataFrames", "Calendar", "UTF16")

using DataFrames, Calendar, UTF16

df = read_stock("spx.csv");
sr = simple_return(df["Close"])
lr = log_return(df["Close"])
ec = equity(df["Close"])


@smell sr[1]    == 0.0
@smell sr[2]    == 0.0049462366    
@smell sr[507]  == 0.003045785    

@smell lr[1]    == 0.0
@smell lr[2]    == 0.0049340441  
@smell lr[507]  == 0.003041156

@smell ec[1]    == NA
@smell ec[2]    == 1.00494623
@smell ec[507]  == 1.09774194 
