###### readtimearray ############

function readtimearray(fname::String)
  blob    = readcsv(fname)
  tstamps = Date{ISOCalendar}[date(i) for i in blob[2:end, 1]]
  vals    = float(blob[2:end, 2:end])
  cnames  = ASCIIString[]
  for b in blob[1, 2:end]
    push!(cnames, b)
  end
  TimeArray(tstamps, vals, cnames)
end
