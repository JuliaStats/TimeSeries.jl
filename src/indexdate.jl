function indexyear(df::DataFrame, t::Int)
  df = copy(df)
  df["year"] = year(df["Date"])
  temp = df[:(year .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexmonth(df::DataFrame, t::Int)
  df = copy(df)
  df["month"] = month(df["Date"])
  temp = df[:(month .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexday(df::DataFrame, t::Int)
  df = copy(df)
  df["day"] = day(df["Date"])
  temp = df[:(day .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexdow(df::DataFrame, t::Int)
  df = copy(df)
  df["dow"] = dayofweek(df["Date"])
  temp = df[:(dow .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

####### no tests for these implementations yet 

function indexhour(df::DataFrame, t::Int)
  df = copy(df)
  df["hour"] = hour(df["Date"])
  temp = df[:(hour .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexminute(df::DataFrame, t::Int)
  df = copy(df)
  df["minute"] = minute(df["Date"])
  temp = df[:(minute .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexsecond(df::DataFrame, t::Int)
  df = copy(df)
  df["second"] = second(df["Date"])
  temp = df[:(second .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexweek(df::DataFrame, t::Int)
  df = copy(df)
  df["week"] = week(df["Date"])
  temp = df[:(week .== $t), :]
  res  = temp[:,1:length(temp)-1]
end

function indexdoy(df::DataFrame, t::Int)
  df = copy(df)
  df["doy"] = dayofyear(df["Date"])
  temp = df[:(doy .== $t), :]
  res  = temp[:,1:length(temp)-1]
end
