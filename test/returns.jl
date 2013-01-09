require("DataFrames", "Calendar", "UTF16")

using DataFrames, Calendar, UTF16

df = read_stock("spx.csv");
ec = equity(df["Close"])


@smell ec[1]    == 1.0
@smell ec[2]    == 1.0049340441190235
@smell ec[507]  == 1.0932552840276681

