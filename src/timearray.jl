##############################################################################

importall Base
importall Stats

##############################################################################

abstract AbstractTimeArray <: Associative{String, Any}
#abstract AbstractTimeArray <: Associative{Any, Any}

##############################################################################

#immutable TimeArray <: AbstractTimeArray
# type TimeArray <: AbstractTimeArray
# 
#   values::Array{Float64}
#   timestamp::Index{CalendarTime} 
#   colnames::Vector{String} 
# 
# 
# # inner contructuctor to enforce the following things:
# # timestamp is of type CalendarTime
# # nrow of timestamp == nrow of values 
# # nrow of each value column is the same 
# 
# end

# show code should:
# print as a string the column name
# print the time as 2012-12-12 by default 


# methods need to be defined for 

# merge
# nrow
# ncol
