# The regex used here is ## ismatch(r"(?i)date", col)? ##
# and needs to be upgrded to match the column data vs column name

function read_time(filename::String)

  df  = readtable(filename, nastrings=[".", "", "NA"])

# check if first row already parsed to Datetime
  typeof(df[1,1]) == Date{ISOCalendar}?
  df:
# otherwise find the column named case-insensitive date
# this is a fragile solution that needs to instead query
# the row for ISO8601 Date format and then perform the parsing
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
