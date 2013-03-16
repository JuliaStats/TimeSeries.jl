##############################################################################

importall Base

##############################################################################

abstract AbstractTimeArray <: Associative{Any, Any}

#################### TimeArray #########################################

abstract AbstractTimeArray

type TimeArray <: AbstractTimeArray
  values::Array{TimeStamp}
  # inner constructor to order rows by x.timestamp
end

# show code should:
# print the timestamp in format YYYY-mm-d


# methods need to be defined for 

# merge
# nrow
# ncol
