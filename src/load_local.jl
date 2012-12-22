function load_local(x)

# load("DataFrames")
# load("Calendar")
# using DataFrames
# using Calendar
# using UTF16

time_based_df = read_table(x);

# foo = convert(Array{UTF16String}, time_based_df[:,1])

 bar = map(x -> parse("yyyy-MM-dd", x), convert(Array{UTF16String}, vector(time_based_df[:,1])))

 within!(time_based_df, quote
         Date = $(bar)
         end);

flipud(time_based_df)

end

