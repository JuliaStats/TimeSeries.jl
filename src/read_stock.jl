function read_stock(csv::ASCIIString)

df = read_table(csv);
time_conversion = map(x -> parse("yyyy-MM-dd", x), 
                     convert(Array{UTF16String}, vector(df[:,1])))
within!(df, quote
        Date = $(time_conversion)
        end);
flipud(df)
end
