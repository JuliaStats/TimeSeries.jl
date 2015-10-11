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

findall(ta::TimeArray{Bool,1}) = find(ta.values)

###### findwhen #################

findwhen(ta::TimeArray{Bool,1}) = ta.timestamp[find(ta.values)]

###### element wrapers ###########

timestamp{T,N}(ta::TimeArray{T,N}) = ta.timestamp
values{T,N}(ta::TimeArray{T,N})    = ta.values
colnames{T,N}(ta::TimeArray{T,N})  = ta.colnames
meta{T,N}(ta::TimeArray{T,N})      = ta.meta
