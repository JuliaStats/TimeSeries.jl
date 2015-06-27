UNARY         = [:+, :-, :!]
MATH_NO_DOT   = [:+, :-, :*, :/, :^, :%]
MATH_DOT      = [:.+, :.-, :.*, :./, :.^, :.%]
COMPARISONS   = [:.>,:.<, :.==, :.>=, :.<=, :.!=]
LOGICAL       = [:&, :|, :$]

SCALAR_OPS    = [MATH_NO_DOT; MATH_DOT; COMPARISONS]
ELEMENT_OPS   = [MATH_DOT; COMPARISONS]
BOOLEAN_OPS   = [LOGICAL; COMPARISONS]

###### Math and Boolean Unary Operators  #####

for op in UNARY
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N})
      cnames  = [string($op) * name for name in ta.colnames]
      basecall(ta, ($op), cnames=cnames) 
    end # function
  end # eval
end # loop

###### Numerical Operations and Comparisons ########

# TimeArray <--> Scalar 
for op in SCALAR_OPS 
  @eval begin
    function ($op){T,N}(ta::TimeArray{T,N}, var::Union(BigInt,Signed,Unsigned,FloatingPoint))
      cnames  = [name * string($op) * string(var) for name in ta.colnames]
      vals = ($op)(ta.values, var)
      TimeArray(ta.timestamp, vals, cnames, ta.meta)
    end # function
  end # eval
end # loop

# Scalar <--> TimeArray
for op in SCALAR_OPS 
  @eval begin
    function ($op){T,N}(var::Union(BigInt,Signed,Unsigned,FloatingPoint), ta::TimeArray{T,N})
      cnames  = [string(var) * string($op) * name for name in ta.colnames]
      vals = ($op)(var, ta.values)
      TimeArray(ta.timestamp, vals, cnames, ta.meta)
    end # function
  end # eval
end # loop

# ND TimeArray <--> MD TimeArray
for op in ELEMENT_OPS 
  @eval begin
    function ($op){T,N,M}(ta1::TimeArray{T,N}, ta2::TimeArray{T,M})
      # first test metadata matches
      ta1.meta == ta2.meta ?
        meta = ta1.meta :
        error("metadata doesn't match")
      # determine array widths and name cols accordingly
      w1 = length(ta1.colnames)
      w2 = length(ta2.colnames)
      if w1 == w2 
        cnames = [ta1.colnames[i]*string($op)*ta2.colnames[i] for i=1:w1]
      elseif w1==1
        cnames = [ta1.colnames[1]*string($op)*ta2.colnames[i] for i=1:w2]
      elseif w2==1
        cnames = [ta1.colnames[i]*string($op)*ta2.colnames[1] for i=1:w1]
      else
        error("arrays must have the same number of columns, or one must be a single column")
      end
      # obtain shared timestamp
      idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
      tstamp = ta1[idx1].timestamp
      # retrieve values that match the Int array matching dates
      vals1  = ta1[idx1].values
      vals2  = ta2[idx2].values
      # compute output values
      vals = ($op)(vals1, vals2)
      TimeArray(tstamp, vals, cnames, meta)
    end # function
  end # eval
end # loop

###### Boolean Operations and Comparisons ###########

# TimeArray <--> Bool 
for op in BOOLEAN_OPS 
  @eval begin
    function ($op){N}(ta::TimeArray{Bool,N}, var::Bool)
      cnames = [name * string($op) * string(var) for name in ta.colnames]
      vals   = ($op)(ta.values, var)
      TimeArray(ta.timestamp, vals, cnames, ta.meta)
    end # function
  end # eval
end # loop

# Bool <--> TimeArray
for op in BOOLEAN_OPS 
  @eval begin
    function ($op){N}(var::Bool, ta::TimeArray{Bool,N})
      cnames = [string(var) * string($op) * name for name in ta.colnames]
      vals   = ($op)(var, ta.values)
      TimeArray(ta.timestamp, vals, cnames, ta.meta)
    end # function
  end # eval
end # loop

# Boolean ND TimeArray <--> Boolean ND TimeArray
for op in BOOLEAN_OPS 
  @eval begin
    function ($op){N}(ta1::TimeArray{Bool,N}, ta2::TimeArray{Bool,N})
      # test column count matches
      length(ta1.colnames) == length(ta2.colnames) ?
        ncols=length(ta1.colnames) :
        error("arrays must have the same number of columns")
      # test metadata matches
      ta1.meta == ta2.meta ?
        meta = ta1.meta :
        error("metadata doesn't match")
      cnames = [ta1.colnames[i]*string($op)*ta2.colnames[i] for i=1:ncols]
      idx1, idx2 = overlaps(ta1.timestamp, ta2.timestamp)
      # obtain shared timestamp
      tstamp = ta1[idx1].timestamp
      # retrieve values that match the Int array matching dates
      vals1  = ta1[idx1].values
      vals2  = ta2[idx2].values
      vals = ($op)(vals1, vals2)
      TimeArray(tstamp, vals, cnames, meta)
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
