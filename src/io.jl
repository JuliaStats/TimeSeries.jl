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

# create IndexedVector and enforce descending order using first valid Datetime column
  enforcer     = col_that_pass[1]
  df[enforcer] = IndexedVector(df[enforcer])
  df[1, enforcer] > df[2, enforcer]? flipud!(df): df

  return df
end
function readtime1(filename::String)

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

# enforce descending order using first valid Datetime column
  enforcer     = col_that_pass[1]
  df[1, enforcer] > df[2, enforcer]? flipud!(df): df

  return df
end
