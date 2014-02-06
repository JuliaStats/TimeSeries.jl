#################################
###### +, -, *, / ###############
#################################

for op in [:.+, :.-, :.*, :./]
  @eval begin
    function ($op){T,N}(ta1::TimeArray{T,N}, ta2::TimeArray{T,N})
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      tstamp = Date{ISOCalendar}[]
      vals   = T[]
      for i in 1:size(ta1.timestamp, 1)
        for j in 1:size(ta2.timestamp, 1)
          if ta1.timestamp[i] == ta2.timestamp[j] 
            push!(tstamp, ta1.timestamp[i]) 
            push!(vals, ($op)(ta1.values[i], ta2.values[j])) 
          end
        end
      end
      TimeArray(tstamp, vals, cname)
    end # function
  end # eval
end # loop

# element-wise operations between a column and Int,Float64
for op in [:.+, :.-, :.*, :./]
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(Int,Float64))
      vals = ($op)([t for t in ta.values], var)
      TimeArray(ta.timestamp, vals, ta.colnames)
    end # function
  end # eval
end # loop
