function indexyear(df::DataFrame, year::Int)
  yindex = zeros(nrow(df))
  [yindex[i] = year(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    yindex = $yindex
    end)

  temp = df[:(yindex .== $year), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexmon(df::DataFrame, month::Int)
  mindex = zeros(nrow(df))
  [mindex[i] = month(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    mindex = $mindex
    end)

  temp = df[:(mindex .== $month), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexday(df::DataFrame, day::Int)
  dindex = zeros(nrow(df))
  [dindex[i] = day(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    dindex = $dindex
    end)

  temp = df[:(dindex .== $day), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end

function indexdow(df::DataFrame, dow::Int)
  dwindex = zeros(nrow(df))
  [dwindex[i] = dayofweek(df[i,1]) for i=1:nrow(df)]

  within!(df, quote
    dwindex = $dwindex
    end)

  temp = df[:(dwindex .== $dow), :]
# super expensive hack
  res  = temp[:,1:length(temp)-1]
end
