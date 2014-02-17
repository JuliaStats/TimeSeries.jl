#################################
# bydate ########################
#################################

for (byfun,datefun) = ((:byyear,:year), (:bymonth,:month), (:byday,:day), (:bydow,:dayofweek), (:bydoy,:dayofyear))
                      # (:byhour,:hour), (:byminute,:minute), (:bysecond,:second)
  @eval begin
    # get array of ints that correspond to dates and call getindex on that
    function ($byfun){T,N}(ta::TimeArray{T,N}, t::Int) 
      boolarray = [[$datefun(ta.timestamp[d]) for d in 1:length(ta.timestamp)] .== t]
      rownums = int(zeros(sum(boolarray)))
      j = 1
      for i in 1:length(boolarray)
        if boolarray[i]
          rownums[j] = i
          j+=1
        end
      end
      ta[rownums]
    end # function
  end # eval
end # loop
 
#################################
# from, to ######################
#################################
 
function from{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[date(y,m,d):last(ta.timestamp)]
end 

function to{T,N}(ta::TimeArray{T,N}, y::Int, m::Int, d::Int)
    ta[ta.timestamp[1]:date(y,m,d)]
end 

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
