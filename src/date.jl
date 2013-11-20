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


# from, to, between and only 

for(nam, func) = ((:from, :>=), 
                  (:to, :<=))
  @eval begin
   function ($nam)(df::DataFrame, y::Int, m::Int, d::Int)
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

function between(df::DataFrame, fy::Int, fm::Int, fd::Int,
                               ty::Int, tm::Int, td::Int)
  d = from(df, fy, fm, fd)
  return to(d, ty, tm, td)
end

function only(df::DataFrame, f::Function)
  foo = df[1,1]:f:df[nrow(df),1] 
  bar = DataFrame(Date = [foo])
  return join(bar, df)
end
