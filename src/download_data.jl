function downloadPrices()

  foo = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=AAPL"`);
  
  bar = foo[2:end]
  baz  = split(bar[1], ',')'
    
    for i in 2:length(bar) 
        baz  = [baz ; split(bar[i], ',')']
    end
  baz
end

function read_yahoo(sa)

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

