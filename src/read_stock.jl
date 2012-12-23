function read_stock(x)

stock_df = read_table(x);
  time_coversion = map(x -> parse("yyyy-MM-dd", x), 
           convert(Array{UTF16String},  
                  vector(stock_df[:,1])))
  within!(stock_df, quote
         Date = $(time_coversion)
         end);
  flipud(stock_df)
end
