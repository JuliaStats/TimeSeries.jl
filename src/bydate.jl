# by family
for (byfun,calfun) = ((:byyear,:year), 
                      (:bymonth,:month), 
                      (:byday,:day),
                      (:bydow,:dayofweek), 
                      (:bydoy,:dayofyear))
                      # (:byhour,:hour), 
                      # (:byminute,:minute), 
                      # (:bysecond,:second),
    @eval begin
        function ($byfun)(df::DataFrame, t::Int)
            df[([$calfun(d) for d in df["Date"]]) .== t, :]
        end
    end
end

# greater, less family


for(nam, func) = ((:gtrows, :>), 
                  (:ltrows, :<), 
                  (:gterows, :>=), 
                  (:lterows, :<=), 
                  (:eqrows, :(==)))
  @eval begin
   function ($nam)(df::DataFrame, m::Int, d::Int, y::Int)
      p = Int[]
      for i in 1:nrow(df)
        if ($func)(df[i, "Date"], date(y, m, d))
        push!(p, i)
        end
      end
    df[p,:]
    end
  end
end


# for (fun,op) = ((:gt, :.>),
#                 (:gte, :.>=),
#                 (:lt, :.<),
#                 (:lte, :.<=))
#   @eval begin
#     function ($fun)(df::DataFrame, month::Int, day::Int, year::Int)
#       df[:(Date ($op) $date($year, $month, $day)),:]
#     end
#   end
# end
