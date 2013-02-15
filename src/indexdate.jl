for (indexfun,calfun) = ((:indexyear,:year), (:indexmonth,:month), (:indexday,:day),
                         (:indexdow,:dayofweek))
    @eval begin
        function ($indexfun)(df::DataFrame, t::Int)
            userow = ($calfun)(df["Date"]) .== t
            df[userow, :]
        end
    end
end

####### no tests for these implementations yet
####### After adding tests, move into the above loop

for (indexfun,calfun) = ((:indexhour,:hour), (:indexminute,:minute), (:indexsecond,:second),
                         (:indexdoy,:dayofyear))
    @eval begin
        function ($indexfun)(df::DataFrame, t::Int)
            userow = ($calfun)(df["Date"]) .== t
            df[userow, :]
        end
    end
end
