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

#################################
###### lag, lead ################
#################################
  
function lag{T,N}(ta::TimeArray{T,N}; period::Int=1) 
    TimeArray(ta.timestamp[period+1:end], ta.values[1:length(ta)-period], ta.colnames)
end

function lag{T,N}(ta::TimeArray{T,N}, n::Int) 
    TimeArray(ta.timestamp[n+1:end], ta.values[1:length(ta)-n], ta.colnames)
end

function lead{T,N}(ta::TimeArray{T,N}; period::Int=1) 
    TimeArray(ta.timestamp[1:length(ta)-period], ta.values[period+1:end], ta.colnames)
end

function lead{T,N}(ta::TimeArray{T,N}, n::Int) 
    TimeArray(ta.timestamp[1:length(ta)-n], ta.values[n+1:end], ta.colnames)
end

#################################
###### percentchange ############
#################################

function percentchange{T,N}(ta::TimeArray{T,N}; method="simple") 
    logreturn = log(ta.values)[2:end] .- log(lag(ta).values)
#    logreturn = T[ta.values[t] for t in 1:length(ta)] |> log |> diff

    if method == "simple" 
      TimeArray(ta.timestamp[2:end], expm1(logreturn), ta.colnames) 
    elseif method == "log" 
      TimeArray(ta.timestamp[2:end], logreturn, ta.colnames) 
    else msg("only simple and log methods supported")
    end
end

#################################
###### moving ###################
#################################

function moving{T,N}(ta::TimeArray{T,N}, f::Function, window::Int) 
    tstamps = ta.timestamp[window:end]
    vals    = zeros(length(ta) - (window-1))
    for i=1:length(vals)
      vals[i] = f(ta.values[i:i+(window-1)])
    end
    TimeArray(tstamps, vals, ta.colnames)
end

#################################
###### upto #####################
#################################

function upto{T,N}(ta::TimeArray{T,N}, f::Function) 
    vals    = zeros(length(ta))
    nextta  = T[]
      for i=1:length(ta)
        vals[i] = f(push!(nextta, ta.values[i]))
      end
    TimeArray(ta.timestamp, vals, ta.colnames)
end

#################################
###### basecall #################
#################################

basecall{T,N}(ta::TimeArray{T,N}, f::Function; cnames=ta.colnames) =  TimeArray(ta.timestamp, f(ta.values), cnames)
