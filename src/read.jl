function read_yahoo(dir::String, filename::String)
csv = strcat(dir, "/", filename)
df = read_table(csv)
time_conversion = map(x -> parse("yyyy-MM-dd", x), 
                     convert(Array{UTF16String}, vector(df[:,1])))
within!(df, quote
        Date = $(time_conversion)
        end)
flipud(df)
end

function read_yahoo(stock::String)
  ydata = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=$stock"`);
  numstring = ydata[2:end]
  sa  = split(numstring[1], ',')'
  for i in 2:length(numstring) 
    sa  = [sa ; split(numstring[i], ',')']
  end
  time_conversion = map(x -> parse("yyyy-MM-dd", x), convert(Array{UTF16String}, sa[:,1]))
  df = DataFrame(quote
     Date  = $time_conversion
     Open  = float($sa[:,2])
     High  = float($sa[:,3])
     Low   = float($sa[:,4])
     Close = float($sa[:,5])
     Vol   =   int($sa[:,6])
     Adj   = float($sa[:,7])
     end)
  flipud(df)
end

yip = read_yahoo









########### function downloadPrices(stock::String)
########### 
###########   foo = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=$stock"`);
###########   
###########   bar = foo[2:end]
###########   baz  = split(bar[1], ',')'
###########     
###########     for i in 2:length(bar) 
###########         baz  = [baz ; split(bar[i], ',')']
###########     end
###########   baz
########### end

