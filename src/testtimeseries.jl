macro timeseries()
  println("")
  reload(Pkg.dir("TimeSeries", "run_tests.jl"))
end


function read_csv_for_testing(dir::String, filename::String)

csv = string(dir, "/", filename)
df  = read_table(csv)

time_conversion = map(x -> parse("yyyy-MM-dd", x), 
                     convert(Array{UTF16String}, vector(df[:,1])))
within!(df, quote
        Date = $(time_conversion)
        end)

flipud(df)
end

