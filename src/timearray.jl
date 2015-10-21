###### type definition ##########

import Base: convert, length, show, getindex, start, next, done, isempty, endof

abstract AbstractTimeSeries

immutable TimeArray{T, N, D<:TimeType, M} <: AbstractTimeSeries

    timestamp::Vector{D}
    values::AbstractArray{T,N}
    colnames::Vector{UTF8String}
    meta::M

    function TimeArray(timestamp::Vector{D},
                       values::AbstractArray{T,N},
                       colnames::Vector{UTF8String},
                       meta::M)
                           nrow, ncol = size(values, 1), size(values, 2)
                           nrow != size(timestamp, 1) ? error("values must match length of timestamp"):
                           ncol != size(colnames,1) ? error("column names must match width of array"):
                           timestamp != unique(timestamp) ? error("there are duplicate dates"):
                           ~(flipdim(timestamp, 1) == sort(timestamp) || timestamp == sort(timestamp)) ? error("dates are mangled"):
                           flipdim(timestamp, 1) == sort(timestamp) ? 
                           new(flipdim(timestamp, 1), flipdim(values, 1), colnames, meta):
                           new(timestamp, values, colnames, meta)
    end
end

TimeArray{T,N,D<:TimeType,S<:AbstractString,M}(d::Vector{D}, v::AbstractArray{T,N}, c::Vector{S}, m::M) = TimeArray{T,N,D,M}(d,v,map(utf8,c),m)
TimeArray{T,N,D<:TimeType,S<:AbstractString,M}(d::D, v::AbstractArray{T,N}, c::Vector{S}, m::M) = TimeArray([d],v,map(utf8,c),m)

# when no meta is provided
TimeArray{T,N,D<:TimeType}(d::Vector{D}, v::AbstractArray{T,N}, c) = TimeArray(d,v,c,nothing)
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
    spacetime     = strwidth(string(ta.timestamp[1])) + 3
    firstcolwidth = strwidth(ta.colnames[1])
    colwidth      = Int[]
        for m in 1:ncol
            T == Bool ?
            push!(colwidth, max(strwidth(ta.colnames[m]), 5)) :
            push!(colwidth, max(strwidth(ta.colnames[m]), strwidth(@sprintf("%.2f", maximum(ta.values[:,m]))) + DECIMALS - 2))
        end
  
    # summary line
    print(io, @sprintf("%dx%d %s %s to %s", nrow, ncol, typeof(ta), string(ta.timestamp[1]), string(ta.timestamp[nrow])))
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
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    else
        for i in 1:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(round(Integer, ta.values[i,j]), colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    end
end

###### getindex #################

# single row
function getindex{T,N,D}(ta::TimeArray{T,N,D}, n::Int)
    TimeArray(ta.timestamp[n], ta.values[n,:], ta.colnames, ta.meta)
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
function getindex{T,N,D}(ta::TimeArray{T,N,D}, a::Vector{Int})
    TimeArray(ta.timestamp[a], ta.values[a,:], ta.colnames, ta.meta)
end

# array of 1d rows
function getindex{T,D}(ta::TimeArray{T,1,D}, a::Vector{Int})
    TimeArray(ta.timestamp[a], ta.values[a], ta.colnames, ta.meta)
end

# single column by name 
function getindex{T,N,D}(ta::TimeArray{T,N,D}, s::AbstractString)
    n = findfirst(ta.colnames, s)
    TimeArray(ta.timestamp, ta.values[:, n], UTF8String[s], ta.meta)
end

# array of columns by name
function getindex{T,N,D}(ta::TimeArray{T,N,D}, args::AbstractString...)
    ns = [findfirst(ta.colnames, a) for a in args]
    TimeArray(ta.timestamp, ta.values[:,ns], UTF8String[a for a in args], ta.meta)
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

getindex{T,N,D}(ta::TimeArray{T,N,D}, r::StepRange{D}) = ta[collect(r)]

getindex{T,N,D}(ta::TimeArray{T,N,D}, k::TimeArray{Bool,1}) = ta[findwhen(k)]

# day of week
# getindex{T,N}(ta::TimeArray{T,N}, d::DAYOFWEEK) = ta[dayofweek(ta.timestamp) .== d]

# Define end keyword
endof(ta::TimeArray) = length(ta.timestamp)
