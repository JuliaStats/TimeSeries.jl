for (byfun,calfun) = ((:byyear,:year), (:bymonth,:month), (:byday,:day),
                      (:bydow,:dayofweek), (:byhour,:hour), (:byminute,:minute), 
                      (:bysecond,:second), (:bydoy,:dayofyear))
    @eval begin
        function ($byfun)(df::DataFrame, t::Int)
            df[([year(d) for d in df["Date"]]) .== t, :]
        end
    end
end

