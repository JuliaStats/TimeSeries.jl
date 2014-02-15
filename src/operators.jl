#################################
###### +, -, *, / ###############
#################################

# element-wise mathematical operations between two columns
for op in [:.+, :.-, :.*, :./, :+, :-, :*, :/]
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

# element-wise comparison operations between two columns
for op in [:.>, :.<, :.==, :.>=, :.<=]
  @eval begin
    function ($op){T,N}(ta1::TimeArray{T,N}, ta2::TimeArray{T,N})
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      tstamp = Date{ISOCalendar}[]
      vals   = Bool[]
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

# element-wise mathematical operations between a column and Int,Float64
for op in [:.+, :.-, :.*, :./, :.^, :+, :-, :*, :/]
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(Int,Float64))
      vals = ($op)([t for t in ta.values], var)
      TimeArray(ta.timestamp, vals, ta.colnames)
    end # function
  end # eval
end # loop

# element-wise mathematical operations between an Int,Float64 and column
for op in [:.+, :.-, :.*, :./, :.^, :+, :-, :*, :/]
  @eval begin
    function ($op){T,N}(var::Union(Int,Float64), ta::TimeArray{T,N})
      vals = ($op)(var, [t for t in ta.values])
      TimeArray(ta.timestamp, vals, ta.colnames)
    end # function
  end # eval
end # loop

# element-wise comparison operations between a column and Int,Float64
for op in [:.>, :.<, :.==, :.>=, :.<=]
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(Int,Float64))
      cname  = [ta.colnames[1][1:2] *  string($op) *  string(var)]
      tstamp = Date{ISOCalendar}[]
      vals   = Bool[]
      for i in 1:length(ta)
        push!(vals, ($op)(ta.values[i], var))
      end
      TimeArray(ta.timestamp, vals, cname)
    end # function
  end # eval
end # loop

# element-wise comparison operations between an  Int,Float64 and column
for op in [:.>, :.<, :.==, :.>=, :.<=]
  @eval begin
    function ($op){T,N}(var::Union(Int,Float64), ta::TimeArray{T,N})
      cname  = [ta.colnames[1][1:2] *  string($op) *  string(var)]
      tstamp = Date{ISOCalendar}[]
      vals   = Bool[]
      for i in 1:length(ta)
        push!(vals, ($op)(var, ta.values[i]))
      end
      TimeArray(ta.timestamp, vals, cname)
    end # function
  end # eval
end # loop
