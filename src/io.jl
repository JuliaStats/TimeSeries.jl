function read_time(filename::String)

  df  = readtable(filename)

# find the column named date
  for col in colnames(df)
    ismatch(r"(?i)date", col)?
    df[col] = Date[date(d) for d in df[col]]:
    Nothing
  end

# create IndedxedVector
  for col in colnames(df)
    ismatch(r"(?i)date", col)?
    df[col] =  IndexedVector(df[col]):
    Nothing
  end

# enforce descending order
  for col in colnames(df)
    ismatch(r"(?i)date", col) && df[1,col] > df[2, col]?
    flipud!(df):
    Nothing
  end

  return df
end
