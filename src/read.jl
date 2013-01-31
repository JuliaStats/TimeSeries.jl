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

function read_yahoo(stock::String, fm::Int, fd::Int, fy::Int, tm::Int, td::Int, ty::Int)
  fm-=1
  tm-=1
  ydata = readlines(`curl -s "http://ichart.finance.yahoo.com/table.csv?s=$stock&a=$fm&b=$fd&c=$fy&d=$tm&e=$td&f=$ty"`)
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

read_yahoo(stock::String) = read_yahoo(stock::String,  month(now()), day(now()), year(now())-3, month(now()),  day(now()), year(now()))




# alias

yip = read_yahoo










