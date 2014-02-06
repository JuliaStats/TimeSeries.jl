#################################
###### +, -, *, / ###############
#################################
 
# element-wise operations between two columns
#for op in [:.+, :.-, :.*, :./, :.>, :.<, :.>=, :.<=, :.==] # return Bools for comparison operators?
for op in [:.+, :.-, :.*, :./]
  @eval begin
    #function ($op){T}(ta1::TimeArray{T,1}, ta2::TimeArray{T,1})
    function ($op){T}(ta1::TimeArray{T}, ta2::TimeArray{T})
    #function ($op){T}(ta1, ta2)
      cname  = [ta1.colnames[1][1:2] *  string($op) *  ta2.colnames[1][1:2]]
      tstamp = Date{ISOCalendar}[]
      vals   = T[]
      for i in 1:size(ta1.timestamp, 1)
        for j in 1:size(ta2.timestamp, 1)
          if ta1.timestamp[i] == ta2.timestamp[j] 
            push!(tstamp, ta1.timestamp[i]) 
            push!(vals, ($op)(ta1.values[i], ta2.values[j])) 
          end
        end
      end
      TimeArray(tstamp, vals, cname)
    end # function
  end # eval
end # loop

#         
# # operations between a column and Int,Float64
# for op in [:+, :-, :*, :/, :.+, :.-, :.*, :./]
#   @eval begin
#     function ($op){T,V}(sp::SeriesPair{T,V}, var::Union(Int,Float64))
#       SeriesPair(sp.timestamp, ($op)(sp.value, var))
#     end
#   end
# end
