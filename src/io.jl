function read_time(filename::String, fmt::String, indexby::Int)
  df = read_table(filename)
  within!(df, :(Date = $parse_date($fmt, $df[:,$indexby])))
  df["Date"] = IndexedVector(df["Date"])
  if df[1,1] > df[2,1]
    flipud!(df)
  end
  df
end

read_time(filename) = read_time(filename, "yyyy-MM-dd", 1)
