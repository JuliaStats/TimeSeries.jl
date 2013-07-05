function read_time(filename::String, fmt::String)
  cdf        = readtable(filename)
  cnames     = colnames(cdf)
  time_array = CalendarTime[]

  for i in 1:nrow(cdf)
    push!(time_array, Calendar.parse("yyyy-MM-dd", cdf[i,1]))
  end

  df = @DataFrame("Date" => time_array)

  for i in 2:length(cnames)
    colname  = cnames[i]
    within!(df, :($colname = $cdf[:,$i]))
  end

  df["Date"] = IndexedVector(df["Date"])

  if df[1,"Date"] > df[2, "Date"]
    flipud!(df)
  end
  df
end

read_time(filename) = read_time(filename, "yyyy-MM-dd")
