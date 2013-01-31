function indexyear(df::DataFrame, t::Int)
  tindex = zeros(nrow(df))
  [tindex[i] = year(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    tindex = $tindex
    end)

  temp = df[:(tindex .== $t), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexmonth(df::DataFrame, t::Int)
  tindex = zeros(nrow(df))
  [tindex[i] = month(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    tindex = $tindex
    end)

  temp = df[:(tindex .== $t), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexday(df::DataFrame, t::Int)
  tindex = zeros(nrow(df))
  [tindex[i] = day(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    tindex = $tindex
    end)

  temp = df[:(tindex .== $t), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexdow(df::DataFrame, t::Int)
  tindex = zeros(nrow(df))
  [tindex[i] = dayofweek(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    tindex = $tindex
    end)

  temp = df[:(tindex .== $t), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

