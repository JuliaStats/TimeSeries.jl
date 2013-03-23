function maxclose(x::Array{TimeStamp{OHLCVA},N})
  x[Cl(x) .== max(Cl(x))]
end

