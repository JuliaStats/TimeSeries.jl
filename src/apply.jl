UNARY = [:+, :-, :~, :!, :abs, :sign, :sqrt, :cbrt,
          :log, :log2, :log10, :log1p,
          :exp, :exp2, :exp10, :expm1,
          :cos, :sin, :tan, :cosd, :sind, :tand,
          :acos, :asin, :atan, :acosd, :asind, :atand,
          :isnan, :isinf
        ]
MATH_DOTONLY    = [:.+, :.-, :.*, :./, :.%, :.^]
MATH_ALL        = [MATH_DOTONLY; [:+, :-, :*, :/, :%]]
COMPARE_DOTONLY = [:.>, :.<, :.==, :.>=, :.<=, :.!=]
BOOLEAN_OPS     = [:&; :|; :$; COMPARE_DOTONLY]

for op in [UNARY; MATH_ALL; BOOLEAN_OPS]
    eval(Expr(:import, :Base, op))
end # for

import Base.diff

###### Unary operators and functions ################

# TimeArray
for op in UNARY
    @eval begin
        function ($op){T,N}(ta::TimeArray{T,N})
            cnames  = [string($op) * name for name in ta.colnames]
            vals = ($op)(ta.values)
            TimeArray(ta.timestamp, vals, cnames, ta.meta)
        end # function
    end # eval
end # loop

###### Numerical operations and comparisons #########

# TimeArray <--> Scalar
for op in [MATH_ALL; COMPARE_DOTONLY]
    @eval begin
        function ($op){T<:Number,N}(ta::TimeArray{T,N}, var::Number)
            cnames  = [name * string($op) * string(var) for name in ta.colnames]
            vals = ($op)(ta.values, var)
            TimeArray(ta.timestamp, vals, cnames, ta.meta)
        end # function
    end # eval
end # loop

# Scalar <--> TimeArray
for op in [MATH_ALL; COMPARE_DOTONLY]
    @eval begin
        function ($op){T<:Number,N}(var::Number, ta::TimeArray{T,N})
            cnames  = [string(var) * string($op) * name for name in ta.colnames]
            vals = ($op)(var, ta.values)
            TimeArray(ta.timestamp, vals, cnames, ta.meta)
        end # function
    end # eval
end # loop

# ND TimeArray <--> MD TimeArray
for op in [MATH_DOTONLY; COMPARE_DOTONLY]
    @eval begin
        function ($op){S<:Number,T<:Number,N,M}(ta1::TimeArray{S,N}, ta2::TimeArray{T,M})

            # first test metadata matches
            meta = ta1.meta == ta2.meta ? ta1.meta : Void

            # determine array widths and name cols accordingly
            w1, w2  = length(ta1.colnames), length(ta2.colnames)
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
            vals1, vals2 = ta1[idx1].values, ta2[idx2].values

            # compute output values
            vals = ($op)(vals1, vals2)
            TimeArray(tstamp, vals, cnames, meta)

        end # function
    end # eval
end # loop

###### Boolean operations and comparisons ###############

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
# Doesn't support broadcasting since it isn't supported by Base either
for op in BOOLEAN_OPS
    @eval begin
        function ($op){N}(ta1::TimeArray{Bool,N}, ta2::TimeArray{Bool,N})
            # test column count matches
            length(ta1.colnames) == length(ta2.colnames) ?
              ncols=length(ta1.colnames) :
              error("arrays must have the same number of columns")
            # test metadata matches
            ta1.meta == ta2.meta ? meta = ta1.meta : error("metadata doesn't match")
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

function lag{T,N}(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0)

    if period != 0
      warn("the period kwarg is deprecated, use lag(ta::TimeArray, period::Int) instead")
      n = period
    end #if

    if padding
        paddedvals = [NaN*ones(n, length(ta.colnames)); ta.values[1:end-n, :]]
        ta = TimeArray(ta.timestamp, paddedvals, ta.colnames, ta.meta)
    else
        ta = TimeArray(ta.timestamp[1+n:end], ta.values[1:end-n, :], ta.colnames, ta.meta)
    end #if

    N == 1 && (ta = ta[ta.colnames[1]])
    return ta

end #lag

function lead{T,N}(ta::TimeArray{T,N}, n::Int=1; padding::Bool=false, period::Int=0)

    if period != 0
      warn("the period kwarg is deprecated, use lead(ta::TimeArray, period::Int) instead")
      n = period
    end #if

    if padding
        paddedvals = [ta.values[1+n:end, :]; NaN*ones(n, length(ta.colnames))]
        ta = TimeArray(ta.timestamp, paddedvals, ta.colnames, ta.meta)
    else
        ta = TimeArray(ta.timestamp[1:end-n], ta.values[1+n:end, :], ta.colnames, ta.meta)
    end #if

    N == 1 && (ta = ta[ta.colnames[1]])
    return ta

end #lead

###### diff #####################

# TODO: Support higher-order differencing?
function diff(ta::TimeArray; padding::Bool=false)
    cols = ta.colnames
    ta = ta .- lag(ta, padding=padding)
    ta.colnames[:] = cols
    return ta
end #diff

###### percentchange ############

function percentchange(ta::TimeArray, returns::Symbol=:simple; padding::Bool=false, method::AbstractString="")

    if method != ""
        warn("the method kwarg is deprecated, use percentchange(ta, :methodname) instead")
        returns = symbol(method)
    end #if

    cols = ta.colnames
    ta =  returns == :log ? diff(log(ta), padding=padding) :
          returns == :simple ? expm1(percentchange(ta, :log, padding=padding)) :
          error("returns must be either :simple or :log")
    ta.colnames[:] = cols

   return ta 

end #percentchange

###### moving ###################

function moving{T}(ta::TimeArray{T,1}, f::Function, window::Int; padding::Bool=false)
    tstamps = padding ? ta.timestamp : ta.timestamp[window:end]
    vals    = zeros(ta.values[window:end])
    for i=1:length(vals)
        vals[i] = f(ta.values[i:i+(window-1)])
    end
    padding && (vals = [NaN*ones(window-1); vals])
    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end

function moving{T}(ta::TimeArray{T,2}, f::Function, window::Int; padding::Bool=false)
    tstamps = padding ? ta.timestamp : ta.timestamp[window:end]
    vals    = zeros(ta.values[window:end, :])
    for i=1:size(vals,1), j=1:size(vals, 2)
        vals[i, j] = f(ta.values[i:i+(window-1), j])
    end
    padding && (vals = [NaN*ones(ta.values[1:(window-1), :]); vals])
    TimeArray(tstamps, vals, ta.colnames, ta.meta)
end

###### upto #####################

function upto{T}(ta::TimeArray{T,1}, f::Function)
    vals = zeros(ta.values)
    for i=1:length(vals)
        vals[i] = f(ta.values[1:i])
    end
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

function upto{T}(ta::TimeArray{T,2}, f::Function)
    vals = zeros(ta.values)
    for i=1:size(vals, 1), j=1:size(vals, 2)
        vals[i, j] = f(ta.values[1:i, j])
    end
    TimeArray(ta.timestamp, vals, ta.colnames, ta.meta)
end

###### basecall #################

basecall{T,N}(ta::TimeArray{T,N}, f::Function; cnames=ta.colnames) =  TimeArray(ta.timestamp, f(ta.values), cnames, ta.meta)

###### uniform observations #####

function uniformspaced(ta::TimeArray)
    gap1 = ta.timestamp[2] - ta.timestamp[1]
    i, n, is_uniform = 2, length(ta), true
    while is_uniform & (i < n)
        is_uniform = gap1 == (ta.timestamp[i+1] - ta.timestamp[i])
        i += 1
    end #while
    return is_uniform
end #uniformlyspaced

function uniformspace{T,N}(ta::TimeArray{T,N})
    min_gap = minimum(ta.timestamp[2:end] - ta.timestamp[1:end-1])
    newtimestamp = ta.timestamp[1]:min_gap:ta.timestamp[end]
    emptyta = TimeArray(collect(newtimestamp), zeros(length(newtimestamp), 0), String[], ta.meta)
    ta = merge(emptyta, ta, :left)
    N == 1 && (ta = ta[ta.colnames[1]])
    return ta
end #uniformlyspace

###### dropnan ####################

dropnan(ta::TimeArray, method::Symbol=:all) =
    method == :all ? ta[find(any(!isnan(ta.values), 2))] :
    method == :any ? ta[find(all(!isnan(ta.values), 2))] :
    error("dropnan method must be :all or :any")
