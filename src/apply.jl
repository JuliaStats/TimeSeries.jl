MATH_ALL        = [:.+, :.-, :.*, :./, :.^, :+, :-, :*, :/, :^]
MATH_DOTONLY    = [:.+, :.-, :.*, :./]
COMPARE_DOTONLY = [:.>, :.<, :.==, :.>=, :.<=] 

###### Mathematical operators  ###############

function overlaps(t1, t2)
    i = j = 1
    idx1 = Int[]
    idx2 = Int[]
    while i < length(t1) + 1 && j < length(t2) + 1
        if t1[i] > t2[j]
            j += 1
        elseif t1[i] < t2[j]
            i += 1
        else
            push!(idx1, i)
            push!(idx2, j)
            i += 1
            j += 1
        end
    end
    (idx1, idx2)        
end

# TimeArray <--> TimeArray 
for op in MATH_DOTONLY
  @eval begin
    function ($op){T,N}(ta1::TimeArray{T,N}, ta2::TimeArray{T,N})
      # first test metadata matches
      ta1.meta == ta2.meta ? meta = ta1.meta : error("metadata doesn't match")
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
      # obtain shared timestamp
      tstamp = ta1[idx1].timestamp
      # retrieve values that match the Int array matching dates
      vals1  = ta1[idx1].values
      vals2  = ta2[idx2].values
      vals = Array(T, length(idx1))
      for i in 1:length(vals)
        vals[i] = ($op)(vals1[i], vals2[i])
      end
      TimeArray(tstamp, vals, cname, meta)
    end # function
  end # eval
end # loop

# TimeArray (2d) <--> TimeArray (1d)
for op in MATH_DOTONLY
  @eval begin
    function ($op){T}(ta1::TimeArray{T,2}, ta2::TimeArray{T,1})

       # first test metadata matches
       ta1.meta == ta2.meta ? meta = ta1.meta : error("metadata doesn't match")
       # interate to find when there is a match on timestamp
       counter = Int[]
       for i in 1:length(ta1)
           if in(ta1[i].timestamp[1], ta2.timestamp)
               push!(counter, i)
           end
       end

       # create new shortened versions of ta1 and ta2
       newta1 = ta1[counter]
       newta2 = ta2[newta1.timestamp]

       # operate on the values columns
       vals = ($op)(ta1.values, ta2.values) 

       cnames = repmat([""], length(ta1.colnames))
       for i in 1:length(ta1.colnames)
           cnames[i] = string(ta1.colnames[i])[1:2] * " " *  string($op) * " " *  string(ta2.colnames[1])[1:2]
       end
       TimeArray(newta1.timestamp, vals, cnames, meta)
    end # function
  end # eval
end # loop

# TimeArray <--> Int,Float64
for op in MATH_ALL
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(Int,Float64))
      vals = ($op)([t for t in ta.values], var)
      TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
    end # function
  end # eval
end # loop

# element-wise mathematical operations between an Int,Float64 and column
for op in MATH_ALL
  @eval begin
    function ($op){T,N}(var::Union(Int,Float64), ta::TimeArray{T,N})
      vals = ($op)(var, [t for t in ta.values])
      TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
    end # function
  end # eval
end # loop

###### Comparison operators  ###############

# TimeArray <--> TimeArray 
for op in COMPARE_DOTONLY 
  @eval begin
    function ($op){T,N}(ta1::TimeArray{T,N}, ta2::TimeArray{T,N})
      # first test metadata matches
      ta1.meta == ta2.meta ? meta = ta1.meta : error("metadata doesn't match")
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
      # obtain shared timestamp
      tstamp = ta1[idx1].timestamp
      # retrieve values that match the Int array matching dates
      vals1  = ta1[idx1].values
      vals2  = ta2[idx2].values
      vals = Array(Bool, length(idx1))
      for i in 1:length(vals)
        vals[i] = ($op)(vals1[i], vals2[i])
      end
      TimeArray(tstamp, vals, cname, meta)
    end # function
  end # eval
end # loop

# TimeArray <--> Int,Float64
for op in COMPARE_DOTONLY 
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(Int,Float64))
      cname  = [ta.colnames[1][1:2] *  string($op) *  string(var)]
      vals   = Array(Bool, length(ta))
      for i in 1:length(vals)
        vals[i] = ($op)(ta.values[i], var) 
      end
      TimeArray(ta.timestamp, vals, cname, ta.meta)
    end # function
  end # eval
end # loop

# Int,Float64 <--> TimeArray
for op in COMPARE_DOTONLY 
  @eval begin
    function ($op){T,N}(var::Union(Int,Float64), ta::TimeArray{T,N})
      cname  = [ta.colnames[1][1:2] *  string($op) *  string(var)]
      vals   = Array(Bool, length(ta))
      for i in 1:length(vals)
        vals[i] = ($op)(var, ta.values[i])
      end
      TimeArray(ta.timestamp, vals, cname, ta.meta)
    end # function
  end # eval
end # loop

###### lag, lead ################
  
function lag{T,N}(ta::TimeArray{T,N}; period::Int=1) 
    N == 1 ?
    TimeArray(ta.timestamp[period+1:end], ta.values[1:length(ta)-period], ta.colnames, ta.meta) :
    TimeArray(ta.timestamp[period+1:end], ta.values[1:length(ta)-period,:], ta.colnames, ta.meta)
end

function lag{T,N}(ta::TimeArray{T,N}, n::Int) 
    N == 1 ?
    TimeArray(ta.timestamp[n+1:end], ta.values[1:length(ta)-n], ta.colnames, ta.meta) :
    TimeArray(ta.timestamp[n+1:end], ta.values[1:length(ta)-n, :], ta.colnames, ta.meta)
end

function lead{T,N}(ta::TimeArray{T,N}; period::Int=1) 
    N == 1 ?
    TimeArray(ta.timestamp[1:length(ta)-period], ta.values[period+1:end], ta.colnames, ta.meta) :
    TimeArray(ta.timestamp[1:length(ta)-period], ta.values[period+1:end, :], ta.colnames, ta.meta)
end

function lead{T,N}(ta::TimeArray{T,N}, n::Int) 
    N == 1 ?
    TimeArray(ta.timestamp[1:length(ta)-n], ta.values[n+1:end], ta.colnames, ta.meta) :
    TimeArray(ta.timestamp[1:length(ta)-n], ta.values[n+1:end, :], ta.colnames, ta.meta)
end

###### percentchange ############

function percentchange{T,N}(ta::TimeArray{T,N}; method="simple") 
    logreturn = log(ta.values)[2:end] .- log(lag(ta).values)
#    logreturn = T[ta.values[t] for t in 1:length(ta)] |> log |> diff

    if method == "simple" 
      TimeArray(ta.timestamp[2:end], expm1(logreturn), ta.colnames, ta.meta) 
    elseif method == "log" 
      TimeArray(ta.timestamp[2:end], logreturn, ta.colnames, ta.meta) 
    else msg("only simple and log methods supported")
    end
end

###### moving ###################

function moving{T,N}(ta::TimeArray{T,N}, f::Function, window::Int) 
    tstamps = ta.timestamp[window:end]
    vals    = zeros(length(ta) - (window-1))
    for i=1:length(vals)
      vals[i] = f(ta.values[i:i+(window-1)])
    end
    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end

###### upto #####################

function upto{T,N}(ta::TimeArray{T,N}, f::Function) 
    vals    = zeros(length(ta))
    nextta  = T[]
      for i=1:length(ta)
        vals[i] = f(push!(nextta, ta.values[i]))
      end
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

###### basecall #################

basecall{T,N}(ta::TimeArray{T,N}, f::Function; cnames=ta.colnames) =  TimeArray(ta.timestamp, f(ta.values), cnames, ta.meta)
