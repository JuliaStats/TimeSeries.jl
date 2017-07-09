###### type definition ##########

import Base: convert, length, show, getindex, start, next, done, isempty, endof

abstract type AbstractTimeSeries end

struct TimeArray{T, N, D <: TimeType, A <: AbstractArray{T, N}} <: AbstractTimeSeries

    timestamp::Vector{D}
    values::A
    colnames::Vector{String}
    meta::Any

    function TimeArray{T, N, D, A}(
            timestamp::AbstractVector{D},
            values::A,
            colnames::Vector{String},
            meta::Any) where {T, N, D <: TimeType, A <: AbstractArray{T, N}}
        nrow, ncol = size(values, 1, 2)

        if nrow != size(timestamp, 1)
            error("values must match length of timestamp")
        elseif ncol != size(colnames, 1)
            error("column names must match width of array")
        elseif timestamp != unique(timestamp)
            error("there are duplicate dates")
        elseif !(flipdim(timestamp, 1) == sort(timestamp) || issorted(timestamp))
            error("dates are mangled")
        elseif flipdim(timestamp, 1) == sort(timestamp)
            new(flipdim(timestamp, 1), flipdim(values, 1),
                replace_dupes(colnames), meta)
        else
            new(timestamp, values, replace_dupes(colnames), meta)
        end
    end
end

TimeArray{T,N,D<:TimeType,S<:AbstractString}(d::AbstractVector{D}, v::AbstractArray{T,N}, c::Vector{S}, m::Any) =
        TimeArray{T,N,D,typeof(v)}(d,v,map(String,c),m)
TimeArray{T,N,D<:TimeType,S<:AbstractString}(d::D, v::AbstractArray{T,N}, c::Vector{S}, m::Any) =
        TimeArray{T,N,D,typeof(v)}([d],v,map(String,c),m)

# when no column names are provided - meta is forced to nothing
TimeArray{T,N,D<:TimeType}(d::AbstractVector{D}, v::AbstractArray{T,N}) = TimeArray(d,v,fill("", size(v,2)),nothing)
TimeArray{T,N,D<:TimeType}(d::D, v::AbstractArray{T,N}) = TimeArray([d],v,fill("", size(v,2)),nothing)

# when no meta is provided
TimeArray{T,N,D<:TimeType}(d::AbstractVector{D}, v::AbstractArray{T,N}, c) = TimeArray(d,v,c,nothing)
TimeArray{T,N,D<:TimeType}(d::D, v::AbstractArray{T,N}, c) = TimeArray([d],v,c,nothing)


###### conversion ###############

convert(::Type{TimeArray{Float64,1}}, x::TimeArray{Bool,1}) = TimeArray(x.timestamp, map(Float64, x.values), x.colnames, x.meta)
convert(::Type{TimeArray{Float64,2}}, x::TimeArray{Bool,2}) = TimeArray(x.timestamp, map(Float64, x.values), x.colnames, x.meta)

convert(x::TimeArray{Bool,1}) = convert(TimeArray{Float64,1}, x::TimeArray{Bool,1})
convert(x::TimeArray{Bool,2}) = convert(TimeArray{Float64,2}, x::TimeArray{Bool,2})

###### length ###################

length(ata::AbstractTimeSeries) = length(ata.timestamp)

###### iterator protocol #########

start(ta::TimeArray)   = 1
next(ta::TimeArray,i)  = ((ta.timestamp[i],ta.values[i,:]),i+1)
done(ta::TimeArray,i)  = (i > length(ta))
isempty(ta::TimeArray) = (length(ta) == 0)

###### show #####################

function show{T,N}(io::IO, ta::TimeArray{T,N})

    # variables
    nrow          = size(ta.values, 1)
    ncol          = size(ta.values, 2)
    intcatcher    = falses(ncol)
    for c in 1:ncol
        rowcheck =  trunc(ta.values[:,c]) - ta.values[:,c] .== 0
        if sum(rowcheck) == length(rowcheck)
            intcatcher[c] = true
        end
    end
    spacetime     = nrow > 0 ? strwidth(string(ta.timestamp[1])) + 3 : 3
    firstcolwidth = strwidth(ta.colnames[1])
    colwidth      = Int[]
    for m in 1:ncol
        (T == Bool) || (nrow == 0) ?
        push!(colwidth, max(strwidth(ta.colnames[m]), 5)) :
        push!(colwidth, max(strwidth(ta.colnames[m]), strwidth(@sprintf("%.2f", maximum(ta.values[:,m]))) + DECIMALS - 2))
    end

    # summary line
    @printf(io, "%dx%d %s", nrow, ncol, typeof(ta))
    nrow > 0 && @printf(io, " %s to %s", string(ta.timestamp[1]), string(ta.timestamp[end]))
    println(io, "")
    println(io, "")

   # row label line

    print(io, ^(" ", spacetime), ta.colnames[1], ^(" ", colwidth[1] + 2 -firstcolwidth))

   for p in 2:length(colwidth)
       print(io, ta.colnames[p], ^(" ", colwidth[p] - strwidth(ta.colnames[p]) + 2))
   end
   println(io, "")

  # timestamp and values line
    if nrow > 7
        for i in 1:4
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(round(Integer, ta.values[i,j]), colwidth[j] + 2, " ")) :
            isnan(ta.values[i,j]) ?
            print(io, rpad(MISSING, colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end

        println(io, '\u22EE')

        for i in nrow-3:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(round(Integer, ta.values[i,j]), colwidth[j] + 2, " ")) :
            isnan(ta.values[i,j]) ?
            print(io, rpad(MISSING, colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    elseif nrow > 0
        for i in 1:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(round(Integer, ta.values[i,j]), colwidth[j] + 2, " ")) :
            isnan(ta.values[i,j]) ?
            print(io, rpad(MISSING, colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    end
end

###### getindex #################

# single row
function getindex{T,N,D}(ta::TimeArray{T,N,D}, n::Int)
    # old code for 0.4
    #TimeArray(ta.timestamp[n], ta.values[n,:], ta.colnames, ta.meta)
    # new code for v0.5 to avoid conversion to column vector
    TimeArray(ta.timestamp[n], ta.values[n:n,:], ta.colnames, ta.meta)
end

# single row 1d
function getindex{T,D}(ta::TimeArray{T,1,D}, n::Int)
    TimeArray(ta.timestamp[n], ta.values[[n]], ta.colnames, ta.meta)
end

# range of rows
function getindex{T,N,D}(ta::TimeArray{T,N,D}, r::UnitRange{Int})
    TimeArray(ta.timestamp[r], ta.values[r,:], ta.colnames, ta.meta)
end

# range of 1d rows
function getindex{T,D}(ta::TimeArray{T,1,D}, r::UnitRange{Int})
    TimeArray(ta.timestamp[r], ta.values[r], ta.colnames, ta.meta)
end

# array of rows
function getindex{T,N,D,S<:Integer}(ta::TimeArray{T,N,D}, a::AbstractVector{S})
    TimeArray(ta.timestamp[a], ta.values[a,:], ta.colnames, ta.meta)
end

# array of 1d rows
function getindex{T,D,S<:Integer}(ta::TimeArray{T,1,D}, a::AbstractVector{S})
    TimeArray(ta.timestamp[a], ta.values[a], ta.colnames, ta.meta)
end

# single column by name
function getindex{T,N,D}(ta::TimeArray{T,N,D}, s::AbstractString)
    n = findfirst(ta.colnames, s)
    TimeArray(ta.timestamp, ta.values[:, n], String[s], ta.meta)
end

# array of columns by name
function getindex{T,N,D}(ta::TimeArray{T,N,D}, args::AbstractString...)
    ns = [findfirst(ta.colnames, a) for a in args]
    TimeArray(ta.timestamp, ta.values[:,ns], String[a for a in args], ta.meta)
end

# single date
function getindex{T,N,D}(ta::TimeArray{T,N,D}, d::D)
    idxs = searchsorted(ta.timestamp, d)
    length(idxs) == 1 ? ta[idxs[1]] : nothing
end

# multiple dates
function getindex{T,N,D}(ta::TimeArray{T,N,D}, dates::Vector{D})
    dates = sort(dates)
    idxs, _ = overlaps(ta.timestamp, dates)
    ta[idxs]
end #getindex

# StepRange{Date,...}
getindex{T,N,D}(ta::TimeArray{T,N,D}, r::StepRange{D}) = ta[collect(r)]

getindex{T,N,D}(ta::TimeArray{T,N,D}, k::TimeArray{Bool,1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]

# Define end keyword
endof(ta::TimeArray) = length(ta.timestamp)

# helper methods for inner constructor
function find_dupes_index(cnames)
    idx = Int[]
    for c in 1:length(cnames)
        if contains(string(cnames[1:c-1]), cnames[c])
            push!(idx, c)
        end
    end
    idx
end

function replace_dupes(cnames)
    n=1
    while length(unique(cnames)) != length(cnames)
        ds = find_dupes_index(cnames)
        for d in ds
            if n == 1
                cnames[d] = string(cnames[d], "_$n")
            else
                #cnames[d] = string(cnames[d][1:length(cnames[d])-2], "$n")
                cnames[d] = string(cnames[d][1:length(cnames[d])-length(string(n))-1], "_$n")
            end
        end
    n +=1
    end
    cnames
end
