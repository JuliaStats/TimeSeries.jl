##############################################################################

importall Base

##############################################################################

abstract AbstractTimeArray <: Associative{Any, Any}

#################### TimeArray #########################################

type TimeArray <: AbstractTimeArray
  values::Array{TimeStamp}
  # inner constructor to order rows by x.timestamp
end

# empty TimeArray
TimeArray() = TimeArray({}, {})



# show code should:
# print the timestamp in format YYYY-mm-d

# methods need to be defined for 

# merge
# nrow
# ncol


################ Constructor ideas ######################

# given an n x 2 DataFrame d
# df = read_table(Pkg.dir("TimeSeries/test/data/spx.csv"));
# d = df[:,1:2]


#   r,c = size(d)
#   
#   var = [TimeStamp(parse("yyyy-MM-dd", d[1,1]), d[1,2])]
#
#   for i in 2:r
#     val = TimeStamp(parse("yyyy-MM-dd", d[i,1]), d[i,2])
#     var = push!(var, val)
#   end


