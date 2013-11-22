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

