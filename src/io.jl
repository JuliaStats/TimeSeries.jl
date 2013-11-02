function readtime(filename::String)

  df  = readtable(filename, nastrings=[".", "", "NA"])

# find columns that have been parsed as Strings by readtable
  col_to_test = String[]

  for col_data in df[1,:]
    typeof(df[1,col_data[1]]) == UTF8String?
      push!(col_to_test, col_data[1]):
    nothing
  end

# test each column's data to see if Datetime will parse it
col_that_pass = String[]

for colname in col_to_test
  d = match(r"[-|\s|\/|.]", df[1,colname])
  d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
  if length(bar) == 3
    push!(col_that_pass, colname)
  end
end

# parse column(s) that pass the Datetime regex test
for col in col_that_pass
  df[col_that_pass] = Date[date(d) for d in df[col]]
end

################# # check if first row already parsed to Datetime
################# 
#################   typeof(df[1,1]) == Date{ISOCalendar}?
#################   df:
################# # otherwise find the column named case-insensitive date
################# # this is a fragile solution that needs to instead query
################# # the row for ISO8601 Date format and then perform the parsing
#################   for col in colnames(df)
#################     ismatch(r"(?i)date", col)?
#################     df[col] = Date[date(d) for d in df[col]]:
#################     Nothing
#################   end
################# 
################# # create IndedxedVector
#################   for col in colnames(df)
#################     ismatch(r"(?i)date", col)?
#################     df[col] =  IndexedVector(df[col]):
#################     Nothing
#################   end
################# 
################# # enforce descending order
#################   for col in colnames(df)
#################     ismatch(r"(?i)date", col) && df[1,col] > df[2, col]?
#################     flipud!(df):
#################     Nothing
#################   end

# create IndexedVector and  enforce descending order using first valid Datetime column
  enforcer     = col_that_pass[1]
  df[enforcer] = IndexedVector(df[enforcer]):
  df[1, enforcer] > df[2, enforcer]? flipud!(df): df

  return df
end
