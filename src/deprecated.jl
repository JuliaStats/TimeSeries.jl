import Base.values

# deprecated by() ############################

function by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) 
    warn("by(ta::TimeArray, t::Int; period::Function) is being deprecated.\nPlease use when(ta::TimeArray, period::Function, t::Int)")
    boolarray = [[period(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t;] # odd syntax for t; but just t deprecated
    rownums = round(Int64, zeros(sum(boolarray)))
    j = 1
    for i in 1:length(boolarray)
        if boolarray[i]
            rownums[j] = i
            j+=1
        end
    end
    ta[rownums]
end 
 
function by{T,N}(ta::TimeArray{T,N}, t::ASCIIString; period::Function=day) 
    warn("by(ta::TimeArray, t::ASCIIString; period::Function) is being deprecated.\nPlease use when(ta::TimeArray, period::Function, t::ASCIIString)")
    boolarray = [[period(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t;] # odd syntax for t; but just t deprecated
    rownums = round(Int64, zeros(sum(boolarray)))
    j = 1
    for i in 1:length(boolarray)
        if boolarray[i]
            rownums[j] = i
            j+=1
        end
    end
    ta[rownums]
end 

# deprecated to / from methods

function to(ta::TimeArray, y::Int, m::Int, d::Int)
    warn("to(ta::TimeArray, y::Int, m::Int, d::Int) is being deprecated.\nPlease use to(ta::TimeArray, d::TimeType) instead")
    return to(ta, Date(y,m,d))
end #to

function from(ta::TimeArray, y::Int, m::Int, d::Int)
    warn("from(ta::TimeArray, y::Int, m::Int, d::Int) is being deprecated.\nPlease use from(ta::TimeArray, d::TimeType) instead")
    return from(ta, Date(y,m,d))
end #from
