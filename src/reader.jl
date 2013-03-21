function imfred(econdata::String)
  fdata = readlines(`curl -s "http://research.stlouisfed.org/fred2/series/$econdata/downloaddata/$econdata.csv"`)
 
  # pre-process columns 
  all_val = fdata[2:end] # all the column values including Date
  vals = map(x -> split(x, ","), all_val) # split each single row string into strings split on , 
 
  # separate the two columns out
  timestamps = map(x -> x[:][1], vals) # take only the first column of values for time
  pre_values = map(x -> x[:][2], vals)  # take only the second column of values 
 
  # account for missing values
  vals = map(x -> x == "" || x == ".\r\n" ? (x = 0) : (x = float(x)), pre_values) #TODO clean this mess up
 
  #construct the Array{TimeStamp}
   ts = [TimeStamp(Calendar.parse("yyyy-MM-dd", timestamps[1]), float(vals[1]))]
   for i in 2:length(timestamps)
     obj = TimeStamp(Calendar.parse("yyyy-MM-dd", timestamps[i]), float(vals[i]))
     ts  = push!(ts, obj)
   end
   ts
end
