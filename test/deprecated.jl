using TimeSeries, MarketData, Base.Dates
FactCheck.setstyle(:compact)
FactCheck.onlystats(true)

facts("deprecated methods") do

    context("deprecated bydate methods correctly subset") do
        @fact by(mdata, 1, period=dayofweek).meta --> "Apple"

        @fact by(cl,4, period=day).timestamp[1]                 --> Date(2000,1,4) 
        @fact by(cl, "Friday", period=dayname).timestamp[1]     --> Date(2000,1,7)
        @fact by(cl,5, period=week).timestamp[1]                --> Date(2000,1,31)
        @fact by(cl,5, period=month).timestamp[1]               --> Date(2000,5,1)
        @fact by(cl, "June", period=monthname).timestamp[1]     --> Date(2000,6,1)
        @fact by(cl,2001, period=year).timestamp[1]             --> Date(2001,1,2)
        @fact by(cl,1, period=dayofweek).timestamp[1]           --> Date(2000,1,3)
        # all the days in the nth week of each month
        @fact by(cl,5, period=dayofweekofmonth).timestamp[1]    --> Date(2000,1,31)
        @fact by(cl,365, period=dayofyear).timestamp[1]         --> Date(2001,12,31)
        @fact by(cl,4, period=quarterofyear).timestamp[1]       --> Date(2000,10,2)
        @fact by(cl,1, period=dayofquarter).timestamp[1]        --> Date(2001,10,1)
    end

    context("deprecated to / from methods select correctly") do
        @fact to(cl, 2000, 01, 01).values    --> to(cl, Date(2000, 01, 01)).values
        @fact to(cl, 2001, 01, 01).values    --> to(cl, Date(2001, 01, 01)).values
        @fact to(cl, 2002, 01, 01).values    --> to(cl, Date(2002, 01, 01)).values
        @fact from(cl, 2000, 01, 01).values  --> from(cl, Date(2000, 01, 01)).values
        @fact from(cl, 2001, 01, 01).values  --> from(cl, Date(2001, 01, 01)).values
        @fact from(cl, 2002, 01, 01).values  --> from(cl, Date(2002, 01, 01)).values
    end

    context("deprecated percentchange methods compute correct values") do
        @fact percentchange(op, method="simple").values  --> percentchange(op, :simple).values
        @fact percentchange(op, method="log").values     --> percentchange(op, :log).values
    end

    context("deprecated findall returns correct indices") do
        @fact findall(cl .> op) --> find(cl .> op)
    end

    context("deprecated collapse squishes correctly") do
        @fact collapse(cl, last).values[1]                  --> 99.50
        @fact collapse(cl, last).timestamp[1]               --> Date(2000,1,7)
        @fact collapse(cl, last, period=month).values[1]    --> 103.75
        @fact collapse(cl, last, period=month).timestamp[1] --> Date(2000,1,31)
    end
end
