#################################
###### findall ##################
#################################

function findall(ta::TimeArray{Bool,1})
    rownums = int(zeros(sum(ta.values)))
    j = 1
    for i in 1:length(ta)
      if ta.values[i]
        rownums[j] = i
        j+=1
      end
    end
    rownums
end
 
#################################
###### findwhen #################
#################################

function findwhen(ta::TimeArray{Bool,1})
    tstamps = [date(1,1,1):years(1):date(sum(ta.values),1,1)]
    j = 1
    for i in 1:length(ta)
      if ta.values[i]
        tstamps[j] = ta.timestamp[i]
        j+=1
      end
    end
    tstamps
end

#################################
###### timing method ############
#################################

# function timeit(f::Function, v::Any, n::Int)
#     p = zeros(n)
#       for i in 1:n
#         p[i] = @elapsed f(v)
#       end
#     mean(p[2:end]) # toss out the first execution from the average
# end
