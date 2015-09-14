import Base.values

# by ############################

function by{T,N}(ta::TimeArray{T,N}, t::Int; period::Function=day) 
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
 
# from, to ######################
 
function from{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[Date(y,m,d):last(ta.timestamp)]
end 

function to{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[ta.timestamp[1]:Date(y,m,d)]
end 

###### findall ##################

function findall(ta::TimeArray{Bool,1})
    rownums = round(Int64, zeros(sum(ta.values)))
    j = 1
    for i in 1:length(ta)
        if ta.values[i]
            rownums[j] = i
            j+=1
        end
    end
    rownums
end
 
###### findwhen #################

function findwhen(ta::TimeArray{Bool,1})
    tstamps = collect(Date(1,1,1):Year(1):Date(sum(ta.values),1,1))
    j = 1
    for i in 1:length(ta)
        if ta.values[i]
            tstamps[j] = ta.timestamp[i]
            j+=1
        end
    end
    tstamps
end

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
