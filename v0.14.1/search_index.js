var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "TimeSeries Overview",
    "title": "TimeSeries Overview",
    "category": "page",
    "text": ""
},

{
    "location": "#TimeSeries-Overview-1",
    "page": "TimeSeries Overview",
    "title": "TimeSeries Overview",
    "category": "section",
    "text": "The TimeSeries package provides convenient methods for working with time series data in Julia."
},

{
    "location": "#Contents-1",
    "page": "TimeSeries Overview",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\n  \"getting_started.md\",\n  \"timearray.md\",\n  \"indexing.md\",\n  \"split.md\",\n  \"modify.md\",\n  \"operators.md\",\n  \"apply.md\",\n  \"combine.md\",\n  \"readwrite.md\",\n  \"dotfile.md\",\n  \"plotting.md\",\n]"
},

{
    "location": "getting_started/#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started/#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "TimeSeries is a registered package. To add it to your Julia packages, simply do the following in REPL:julia> Pkg.add(\"TimeSeries\")Throughout this tutorial, we\'ll be using historical financial data sets, which are made available in the MarketData package. MarketData is also registered and can be added:julia> Pkg.add(\"MarketData\")To create dummy data without using the MarketData package, simply use the following code block:using TimeSeriesusing Dates\ndates = Date(2018, 1, 1):Day(1):Date(2018, 12, 31)\nta = TimeArray(dates, rand(length(dates)))"
},

{
    "location": "timearray/#",
    "page": "The TimeArray time series type",
    "title": "The TimeArray time series type",
    "category": "page",
    "text": ""
},

{
    "location": "timearray/#The-TimeArray-time-series-type-1",
    "page": "The TimeArray time series type",
    "title": "The TimeArray time series type",
    "category": "section",
    "text": "The TimeArray time series type is defined here (with inner constructor code removed for readability):struct TimeArray{T,N,D<:TimeType,A<:AbstractArray{T,N}} <: AbstractTimeSeries{T,N,D}\n    timestamp::Vector{D}\n    values::A # some kind of AbstractArray{T,N}\n    colnames::Vector{Symbol}\n    meta::Any\n\n    # inner constructor code enforcing invariants\nendThere are four fields for the type."
},

{
    "location": "timearray/#timestamp-1",
    "page": "The TimeArray time series type",
    "title": "timestamp",
    "category": "section",
    "text": "The timestamp field consists of a vector of values of a child type of of TimeType - in practise either Date or DateTime. The DateTime type is similar to the Date type except it represents time frames smaller than a day. For the construction of a TimeArray to work, this vector needs to be sorted. If the vector includes dates that are not sequential, the construction of the object will error out. The vector also needs to be ordered from oldest to latest date, but this can be handled by the constructor and will not prohibit an object from being created."
},

{
    "location": "timearray/#values-1",
    "page": "The TimeArray time series type",
    "title": "values",
    "category": "section",
    "text": "The values field holds the data from the time series and its row count must match the length of the timestamp array. If these do not match, the constructor will fail. All the values inside the values array must be of the same type."
},

{
    "location": "timearray/#colnames-1",
    "page": "The TimeArray time series type",
    "title": "colnames",
    "category": "section",
    "text": "The colnames field is a vector of Symbol and contains the names of the columns for each column in the values field. The length of this vector must match the column count of the values array, or the constructor will fail. Since TimeArrays are indexable on column names, duplicate names in the colnames vector will be modified by the inner constructor. Each subsequent duplicate name will be appended by _n where n enumerates from 1."
},

{
    "location": "timearray/#meta-1",
    "page": "The TimeArray time series type",
    "title": "meta",
    "category": "section",
    "text": "The meta field defaults to holding nothing, which is represented by type Nothing. This default is designed to allow programmers to ignore this field. For those who wish to utilize this field, meta can hold common types such as String or more elaborate user-defined types. One might want to assign a name to an object that is immutable versus relying on variable bindings outside of the object\'s type fields."
},

{
    "location": "timearray/#TimeSeries.TimeArray",
    "page": "The TimeArray time series type",
    "title": "TimeSeries.TimeArray",
    "category": "type",
    "text": "TimeArray{T,N,D<:TimeType,A<:AbstractArray{T,N}} <: AbstractTimeSeries{T,N,D}\n\nConstructors\n\nTimeArray(timestamp, values[, colnames, meta=nothing])\nTimeArray(ta::TimeArray; timestamp, values, colnames, meta)\nTimeArray(data::NamedTuple, timestamp=:datetime, meta)\n\nThe second constructor will yields a new TimeArray with the new given fields. Note that the unchanged fields will be shared, there aren\'t any copy for the underlying arrays.\n\nThe third constructor build a TimeArray from a NamedTuple.\n\nArguments\n\ntimestamp::AbstractVector{<:TimeType}: a vector of sorted timestamps, Each element in this vector should be unique.\nvalues::AbstractArray: a data vector or matrix. Its number of rows should match the length of timestamp.\ncolnames::Vector{Symbol}: the column names. Its length should match the column of values.\nmeta::Any: a user-defined metadata.\n\nExamples\n\ndata = (datetime=[DateTime(2018, 11, 21, 12, 0), DateTime(2018, 11, 21, 13, 0)], col1=[10.2, 11.2], col2=[20.2, 21.2], col3=[30.2, 31.2])\nta = TimeArray(data; timestamp=:datetime, meta=\"Example\")\n\n\n\n\n\n"
},

{
    "location": "timearray/#Constructors-1",
    "page": "The TimeArray time series type",
    "title": "Constructors",
    "category": "section",
    "text": "TimeArray"
},

{
    "location": "timearray/#TimeSeries.timestamp",
    "page": "The TimeArray time series type",
    "title": "TimeSeries.timestamp",
    "category": "function",
    "text": "timestamp(ta::TimeArray)\n\nGet the time index of a TimeArray.\n\n\n\n\n\n"
},

{
    "location": "timearray/#Base.values",
    "page": "The TimeArray time series type",
    "title": "Base.values",
    "category": "function",
    "text": "values(ta::TimeArray)\n\nGet the underlying value table of a TimeArray.\n\n\n\n\n\n"
},

{
    "location": "timearray/#TimeSeries.colnames",
    "page": "The TimeArray time series type",
    "title": "TimeSeries.colnames",
    "category": "function",
    "text": "colnames(ta::TimeArray)\n\nGet the column names of a TimeArray.\n\nExamples\n\njulia> colnames(ohlc)\n4-element Array{Symbol,1}:\n :Open\n :High\n :Low\n :Close\n\n\n\n\n\n"
},

{
    "location": "timearray/#TimeSeries.meta",
    "page": "The TimeArray time series type",
    "title": "TimeSeries.meta",
    "category": "function",
    "text": "meta(ta::TimeArray)\n\nGet the user-defined metadata of a TimeArray.\n\n\n\n\n\n"
},

{
    "location": "timearray/#Fields-getter-functions-1",
    "page": "The TimeArray time series type",
    "title": "Fields getter functions",
    "category": "section",
    "text": "There are four field getter functions exported. They are named as same as the field names.timestamp\nvalues\ncolnames\nmetatimestamp\nvalues\ncolnames\nmeta"
},

{
    "location": "indexing/#",
    "page": "Array indexing",
    "title": "Array indexing",
    "category": "page",
    "text": ""
},

{
    "location": "indexing/#Array-indexing-1",
    "page": "Array indexing",
    "title": "Array indexing",
    "category": "section",
    "text": "Indexing out a time series is done with common bracketing semantics."
},

{
    "location": "indexing/#Row-indexing-1",
    "page": "Array indexing",
    "title": "Row indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Integer-1",
    "page": "Array indexing",
    "title": "Integer",
    "category": "section",
    "text": "Example Description Indexing value\n[1] First row of data only single integer\n[1:3] First through third row only integer range\n[1:2:10] Odd row between first to tenth row integer range with step\n[[1:3; 8]] First through third row and eight row integer range & single integer\n[end] Last row Examples in REPL:using MarketDataohlc[1]\nohlc[1:3]\nohlc[1:2:10]\nohlc[[1:3;8]]\nohlc[end]"
},

{
    "location": "indexing/#Date-and-DateTime-1",
    "page": "Array indexing",
    "title": "Date and DateTime",
    "category": "section",
    "text": "Example Description Indexing value\n[Date(2000, 1, 3)] The row containing Jan 3, 2000 timestamp single Date\n[[Date(2000, 1, 3), Date(2000, 2, 4)]] The rows containing Jan 3 & Feb 4, 2000 multiple Dates\n[Date(2000, 1, 3):Day(1):Date(2000, 2, 4)] The rows between Jan 3, 2000 & Feb 4, 2000 range of DateExamples in REPL:using MarketData\nusing Datesohlc[Date(2000, 1, 3)]\nohlc[Date(2000, 1, 3):Day(1):Date(2000, 2, 4)]"
},

{
    "location": "indexing/#Column-indexing-1",
    "page": "Array indexing",
    "title": "Column indexing",
    "category": "section",
    "text": ""
},

{
    "location": "indexing/#Symbol-1",
    "page": "Array indexing",
    "title": "Symbol",
    "category": "section",
    "text": "Example Description Indexing value\n[:Open] The column named :Open single symbol\n[:Open, :Close] The columns named :Open and :Close multiple symbolsExamples in REPL:using MarketData\nusing Datesohlc[:Open]\nohlc[:Open, :Close]"
},

{
    "location": "indexing/#Mixed-approach-1",
    "page": "Array indexing",
    "title": "Mixed approach",
    "category": "section",
    "text": "Example Description Indexing value\n[:Open][1:3] :Open column & first 3 rows single symbol & integer range\n[:Open][Date(2000, 1, 3)] :Open column and Jan 3, 2000 single symbol & DateExamples in REPL:using MarketData\nusing Datesohlc[:Open][1:3]\nohlc[:Open][Date(2000, 1, 3)]"
},

{
    "location": "split/#",
    "page": "Splitting by conditions",
    "title": "Splitting by conditions",
    "category": "page",
    "text": ""
},

{
    "location": "split/#Splitting-by-conditions-1",
    "page": "Splitting by conditions",
    "title": "Splitting by conditions",
    "category": "section",
    "text": "Specific methods for segmenting on time ranges or if condition is met is supported with the following methods."
},

{
    "location": "split/#when-1",
    "page": "Splitting by conditions",
    "title": "when",
    "category": "section",
    "text": "The when methods allows aggregating elements from a TimeArray into specific time periods, such as Mondays or the month of October:using TimeSeries\nusing MarketData\nwhen(cl, dayofweek, 1)\nwhen(cl, dayname, \"Monday\")The period argument holds a valid Date method. Below are currently available alternatives.Dates method Example\nday Jan 3, 2000 = 3\ndayname Jan 3, 2000 = \"Monday\"\nweek Jan 3, 2000 = 1\nmonth Jan 3, 2000 = 1\nmonthname Jan 3, 2000 = \"January\"\nyear Jan 3, 2000 = 2000\ndayofweek Monday = 1\ndayofweekofmonth Fourth Monday in Jan = 4\ndayofyear Dec 31, 2000 = 366\nquarterofyear Dec 31, 2000 = 4\ndayofquarter Dec 31, 2000 = 93"
},

{
    "location": "split/#from-1",
    "page": "Splitting by conditions",
    "title": "from",
    "category": "section",
    "text": "The from method truncates a TimeArray starting with the date passed to the method:using TimeSeries\nusing MarketData\n\nfrom(cl, Date(2001, 12, 27))"
},

{
    "location": "split/#to-1",
    "page": "Splitting by conditions",
    "title": "to",
    "category": "section",
    "text": "The to method truncates a TimeArray after the date passed to the method:using TimeSeries\nusing MarketData\n\nto(cl, Date(2000, 1, 5))"
},

{
    "location": "split/#findwhen-1",
    "page": "Splitting by conditions",
    "title": "findwhen",
    "category": "section",
    "text": "The findwhen method test a condition and returns a vector of Date or DateTime where the condition is true:using TimeSeries\nusing MarketData\n\ngreen = findwhen(ohlc[:Close] .> ohlc[:Open]);\ntypeof(green)\nohlc[green]"
},

{
    "location": "split/#findall-1",
    "page": "Splitting by conditions",
    "title": "findall",
    "category": "section",
    "text": "The findall method tests a condition and returns a vector of Int representing the row in the array where the condition is true:using TimeSeries\nusing MarketData\n\nred = findall(ohlc[:Close] .< ohlc[:Open]);\ntypeof(red)\nohlc[red]"
},

{
    "location": "split/#Splitting-by-head-and-tail-1",
    "page": "Splitting by conditions",
    "title": "Splitting by head and tail",
    "category": "section",
    "text": ""
},

{
    "location": "split/#head-1",
    "page": "Splitting by conditions",
    "title": "head",
    "category": "section",
    "text": "The head method defaults to returning only the first value in a TimeArray. By selecting the second positional argument to a different value, the user can modify how many from the top are selected:using TimeSeries\nusing MarketData\n\nhead(cl)"
},

{
    "location": "split/#tail-1",
    "page": "Splitting by conditions",
    "title": "tail",
    "category": "section",
    "text": "The tail method defaults to returning only the last value in a TimeArray. By selecting the second positional argument to a different value, the user can modify how many from the bottom are selected:using TimeSeries\nusing MarketData\n\ntail(cl)\ntail(cl, 3)"
},

{
    "location": "modify/#",
    "page": "Modify existing TimeArrays",
    "title": "Modify existing TimeArrays",
    "category": "page",
    "text": ""
},

{
    "location": "modify/#Modify-existing-TimeArrays-1",
    "page": "Modify existing TimeArrays",
    "title": "Modify existing TimeArrays",
    "category": "section",
    "text": "Since TimeArrays are immutable, they cannot be altered or changed in-place. In practical application, an existing TimeArray might need to be used to create a new one with many of the same values. This might be thought of as changing the fields of an existing TimeArray, but what actually happens is a new TimeArray is created. To allow the use of an existing TimeArray to create a new one, the update and rename methods are provided."
},

{
    "location": "modify/#update-1",
    "page": "Modify existing TimeArrays",
    "title": "update",
    "category": "section",
    "text": "The update method supports adding new observations only. Older and in-between dates are not supported:using TimeSeries\nusing MarketData\nupdate(cl, Date(2002,1,1), 111.11)\nupdate(cl, Date(2002,1,1), [111.11])\nupdate(ohlc, Date(2002,1,1), [111.11 222.22 333.33 444.44])"
},

{
    "location": "modify/#rename-1",
    "page": "Modify existing TimeArrays",
    "title": "rename",
    "category": "section",
    "text": "The rename method allows the column name(s) to be changed:using TimeSeries\nusing MarketData\nrename(cl, :Close′)\nrename(cl, [:Close′])\nrename(ohlc, [:Open′, :High′, :Low′, :Close′])\nrename(ohlc, :Open => :Open′)\nrename(ohlc, :Open => :Open′, :Close => :Close′)\nrename(ohlc, Dict(:Open => :Open′, :Close => :Close′)...)\nrename(Symbol ∘ uppercase ∘ string, ohlc)\nrename(uppercase, ohlc, String)"
},

{
    "location": "operators/#",
    "page": "Mathematical, comparison, and logical operators",
    "title": "Mathematical, comparison, and logical operators",
    "category": "page",
    "text": ""
},

{
    "location": "operators/#Mathematical,-comparison,-and-logical-operators-1",
    "page": "Mathematical, comparison, and logical operators",
    "title": "Mathematical, comparison, and logical operators",
    "category": "section",
    "text": "TimeSeries supports common mathematical (such as .+), comparison (such as .==) , and logic (such as .&) operators. The operations are only calculated on values that share a timestamp. All of the operations must be treat as dot-call."
},

{
    "location": "operators/#Mathematical-1",
    "page": "Mathematical, comparison, and logical operators",
    "title": "Mathematical",
    "category": "section",
    "text": "Mathematical operators create a TimeArray object where values are computed on shared timestamps when two TimeArray objects are provided. Operations between a single TimeArray and Int or Float are also supported. The number can precede the TimeArray object or vice versa (e.g. cl .+ 2 or 2 .+ cl). Broadcasting single-column arrays over multiple columns to perform operations is also supported.The exclusion of / and ^ from this logic are special cases. In matrix operations / has been confused with being equivalent to the inverse, and because of the confusion base has excluded it. It is likewise excluded here. Base uses ^ to indicate matrix self-multiplication, and so it is not implemented in this context.Operator Description\n.+ arithmetic element-wise addition\n.- arithmetic element-wise subtraction\n.* arithmetic element-wise multiplication\n./ arithmetic element-wise division\n.^ arithmetic element-wise exponentiation\n.% arithmetic element-wise remainder"
},

{
    "location": "operators/#Comparison-1",
    "page": "Mathematical, comparison, and logical operators",
    "title": "Comparison",
    "category": "section",
    "text": "Comparison operators create a TimeArray of type Bool. Values are compared on shared timestamps when two TimeArray objects are provided. Broadcasting single-column arrays over multiple columns to perform comparisons is supported, as are comparisons between a single TimeArray and Int, Float, or Bool values. The semantics of an non-dot operators (>) is unclear, and such operators are not supported.Operator Description\n.> element-wise greater-than comparison\n.< element-wise less-than comparison\n.== element-wise equivalent comparison\n.>= element-wise greater-than or equal comparison\n.<= element-wise less-than or equal comparison\n.!= element-wise not-equivalent comparison"
},

{
    "location": "operators/#Logic-1",
    "page": "Mathematical, comparison, and logical operators",
    "title": "Logic",
    "category": "section",
    "text": "Logical operators are defined for TimeArrays of type Bool and return a TimeArray of type Bool. Values are computed on shared timestamps when two TimeArray objects are provided. Operations between a single TimeArray and Bool are also supported.Operator Description\n.& element-wise logical AND\n.| element-wise logical OR\n.!, .~ element-wise logical NOT\n.⊻ element-wise logical XOR"
},

{
    "location": "apply/#",
    "page": "Apply methods",
    "title": "Apply methods",
    "category": "page",
    "text": ""
},

{
    "location": "apply/#Apply-methods-1",
    "page": "Apply methods",
    "title": "Apply methods",
    "category": "section",
    "text": "Common transformation of time series data involves lagging, leading, calculating change, windowing operations and aggregation operations. Each of these methods include keyword arguments that include defaults."
},

{
    "location": "apply/#lag-1",
    "page": "Apply methods",
    "title": "lag",
    "category": "section",
    "text": "The lag method simply described is putting yesterday\'s value in today\'s timestamp. This is the most common use case, though there are many times the distance between timestamps is not 1 time unit. An arbitrary integer distance for lagging is supported, with the default equal to 1.The value of the cl object on Jan 3, 2000 is 111.94. On Jan 4, 2000 it is 102.50 and on Jan 5, 2000 it\'s 104.0:using TimeSeries\nusing MarketData\ncl[1:3]The lag method moves values up one day:lag(cl[1:3])You will notice that since there is no known value for lagging the first day, the observation on that timestamp is omitted. This behavior is common in time series. When observations are consumed in a transformation, the artifact dates are not preserved with a missingness value. To pad the returned TimeArray with NaN values instead, you can pass padding=true as a keyword argument:lag(cl[1:3], padding=true)"
},

{
    "location": "apply/#lead-1",
    "page": "Apply methods",
    "title": "lead",
    "category": "section",
    "text": "Leading values operates similarly to lagging values, but moves things in the other direction. Arbitrary time distances is also supported:using TimeSeries\nusing MarketData\nlead(cl[1:3])Since we are leading an object of length 3, only two values will be transformed because we have lost a day to the transformation.The cl object is 500 rows long so if we lead by 499 days, we should put the last observation in the object (which happens to be on Dec 31,into the first date\'s value slot:lead(cl, 499)"
},

{
    "location": "apply/#diff-1",
    "page": "Apply methods",
    "title": "diff",
    "category": "section",
    "text": "Differentiating a time series calculates the finite difference between two consecutive points in the time series. The resulting time series will have less points than the original. Those points are filled with NaN values if padding=true.using TimeSeries\nusing MarketData\ndiff(cl)You can calculate higher order differences by using the keyword parameter differences, accepting a positive integer. The default value is differences=1. For instance, passing differences=2 is equivalent to doing diff(diff(cl))."
},

{
    "location": "apply/#percentchange-1",
    "page": "Apply methods",
    "title": "percentchange",
    "category": "section",
    "text": "Calculating change between timestamps is a very common time series operation. We use the terms percent change, returns and rate of change interchangably. Depending on which domain you\'re using time series, you may prefer one name over the other.This package names the function that performs this transformation percentchange. You\'re welcome to change this of course if that represents too many letters for you to type:using TimeSeries\nroc = percentchangeThe percentchange method includes the option to return a simple return or a log return. The default is set to simple:using MarketData\npercentchange(cl)Log returns are popular for downstream calculations since adding returns is simpler than multiplying them. To create log returns, pass the symbol :log to the method:percentchange(cl, :log)"
},

{
    "location": "apply/#moving-1",
    "page": "Apply methods",
    "title": "moving",
    "category": "section",
    "text": "Function signature:moving(f, ta::TimeArray, window; padding=false)\nmoving(ta, window; padding=false) do x\n  ...\nendOften when working with time series, you want to take a sliding window view of the data and perform a calculation on it. The simplest example of this is the moving average. For a 10-period moving average, you take the first ten values, sum then and divide by 10 to get their average. Then you slide the window down one and to the same thing. This operation involves two important arguments: the function that you want to use on your window and the size of the window you want to apply that function over.In our moving average example, we would pass arguments this way:using TimeSeries\nusing MarketData\nusing Statistics\nmoving(mean, cl, 10)As mentioned previously, we lose the first nine observations to the consuming nature of this operation. They are not missing per se, they simply do not exist."
},

{
    "location": "apply/#upto-1",
    "page": "Apply methods",
    "title": "upto",
    "category": "section",
    "text": "Another operation common in time series analysis is an aggregation function. TimeSeries supports this with the upto method. Suppose you want to keep track of the sum of all the values from the beginning to the present timestamp. You would use the upto method like this:using TimeSeries\nusing MarketData\nupto(sum, cl)"
},

{
    "location": "apply/#basecall-1",
    "page": "Apply methods",
    "title": "basecall",
    "category": "section",
    "text": "Because the algorithm for the upto method needs to be optimized further, it might be better to use a base method in its place when one is available. Taking our summation example above, we could instead use the basecall method and realize substantial performance improvements:using TimeSeries\nusing MarketData\nbasecall(cl, cumsum)"
},

{
    "location": "combine/#",
    "page": "Combine methods",
    "title": "Combine methods",
    "category": "page",
    "text": ""
},

{
    "location": "combine/#Combine-methods-1",
    "page": "Combine methods",
    "title": "Combine methods",
    "category": "section",
    "text": "TimeSeries supports merging two TimeArrays, and squishing the timestamp to a longer-term interval while representing values that make sense."
},

{
    "location": "combine/#merge-1",
    "page": "Combine methods",
    "title": "merge",
    "category": "section",
    "text": "The merge method performs joins between two TimeArrays. The default behaviour is to perform an inner join, such that the resulting TimeArray contains only timestamps that both TimeArrays share, and values that correspond to that timestamp.The AAPL object from MarketData has 8,336 rows of data from Dec 12, 1980 to Dec 31, 2013. If we merge it with the CAT object, which contains 13,090 rows of data from Jan 2, 1962 to Dec 31, 2013 we might expect the resulting TimeArray to have 8,336 rows of data, corresponding to the length of AAPL. This assumes that every day that Apple Computer, Inc. traded, Caterpillar, Inc likewise traded. It turns out that this isn\'t true. CAT did not trade on Sep 27, 1985 because Hurricane Glorio shut down the New York Stock Exchage. Apple Computer trades on the electronic NASDAQ and its trading was not halted on that day. The result of the merge should then be 8,335 rows:using TimeSeries\nusing MarketData\nAppleCat = merge(AAPL,CAT);\nlength(AppleCat)Left, right, and outer joins can also be performed by passing the corresponding symbol. These joins introduce NaN values when data for a particular timestamp only exists in one of the series to be merged. For example:merge(op[1:3], cl[2:4], :left)\nmerge(op[1:3], cl[2:4], :right)\nmerge(op[1:3], cl[2:4], :outer)The merge method allows users to specify the value for the meta field of the merged object. When that value is not explicitly provided, merge will concatenate the meta field values, assuming these values to be strings. This covers the vast majority of use cases. In edge cases when users do not provide a meta value and both field values are not strings, the merged object will take on Void as its meta field value:meta(AppleCat)\nCatApple = merge(CAT, AAPL, meta=47);\nmeta(CatApple)\nmeta(merge(AppleCat, CatApple))"
},

{
    "location": "combine/#collapse-1",
    "page": "Combine methods",
    "title": "collapse",
    "category": "section",
    "text": "The collapse method allows for compressing data into a larger time frame. For example, converting daily data into monthly data. When compressing dates, something rational has to be done with the values that lived in the more granular time frame. To define what happens, a function call is made. In our example, we want to compress the daily cl closing prices from daily to monthly. It makes sense for us to take the last value known and have that represented with the corresponding timestamp. A non-exhaustive list of valid time methods is presented below.Dates method Time length\nday daily\nweek weekly\nmonth monthly\nyear yearlyShowing this code in REPL:using TimeSeries\nusing MarketData\ncollapse(cl,month,last)We can also supply the function that chooses the timestamp and the function that determines the corresponding value independently:using Statistics\ncollapse(cl, month, last, mean)"
},

{
    "location": "combine/#vcat-1",
    "page": "Combine methods",
    "title": "vcat",
    "category": "section",
    "text": "The vcat method is used to concatenate time series: if you have two time series with the same columns, but two distinct periods of time, this function can merge them into a single object. Notably, it can be used to merge data that is split into multiple files. Its behaviour is quite different from merge, which does not consider that its arguments are actually the same time series.This concatenation is vertical (vcat) because it does not create columns, it extends existing ones (which are represented vertically).For example:using TimeSeries\na = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16])\nb = TimeArray([Date(2015, 12, 01)], [17])\n[a; b]"
},

{
    "location": "combine/#map-1",
    "page": "Combine methods",
    "title": "map",
    "category": "section",
    "text": "This function allows complete transformation of the data within the time series, with alteration on both the time stamps and the associated values. It works exactly like Base.map: the first argument is a binary function (the time stamp and the values) that returns two values, respectively the new time stamp and the new vector of values. It does not perform any kind of compression like collapse, but rather transformations.The simplest example is to postpone all time stamps in the given time series, here by one year:using TimeSeries\nusing Dates\nta = TimeArray([Date(2015, 10, 01), Date(2015, 11, 01)], [15, 16])\nmap((timestamp, values) -> (timestamp + Year(1), values), ta)"
},

{
    "location": "readwrite/#",
    "page": "I/O",
    "title": "I/O",
    "category": "page",
    "text": ""
},

{
    "location": "readwrite/#I/O-1",
    "page": "I/O",
    "title": "I/O",
    "category": "section",
    "text": "Reading/writing a csv file into a TimeArray object is supported."
},

{
    "location": "readwrite/#readtimearray-1",
    "page": "I/O",
    "title": "readtimearray",
    "category": "section",
    "text": "The readtimearray method is a wrapper for the DelimitedFiles.readdlm method that returns a TimeArray.readtimearray(fname; delim=\',\', meta=nothing, format=\"\")The fname argument is a string that represents the location and name of the csv file that you wish to parse into a TimeArray object. Optionally, you can add a value to the meta field.More generally, this function accepts arbitrary delimiters with delim, just like DelimitedFiles.readdlm.For DateTime data that has odd formatting, a format argument is provided where users can pass the format of their data.For example:ta = readtimearray(\"close.csv\", format=\"dd/mm/yyyy HH:MM\", delim=\';\')A more robust regex parsing engine is planned so users will not need to pass a time format for anything but the most edge cases."
},

{
    "location": "readwrite/#writetimearray-1",
    "page": "I/O",
    "title": "writetimearray",
    "category": "section",
    "text": "The writetimearray method writes a TimeArray to the specified file as comma-separated values. For example:julia> writetimearray(cl[1:5], \"close.csv\")\n\nshell> cat close.csv\nTimestamp,Close\n2000-01-03,111.94\n2000-01-04,102.5\n2000-01-05,104.0\n2000-01-06,95.0\n2000-01-07,99.5"
},

{
    "location": "dotfile/#",
    "page": "Customize TimeArray printing",
    "title": "Customize TimeArray printing",
    "category": "page",
    "text": ""
},

{
    "location": "dotfile/#Customize-TimeArray-printing-1",
    "page": "Customize TimeArray printing",
    "title": "Customize TimeArray printing",
    "category": "section",
    "text": "A dot file named .timeseriesrc sets three variables that control how TimeArrays are displayed. This doesn\'t change the underlying TimeArray and only controls how values are printed to REPL.Here is an handy way to edit it:julia> using TimeSeries\n\njulia> edit(joinpath(dirname(pathof(TimeSeries)), \".timeseriesrc.jl\"))"
},

{
    "location": "dotfile/#DECIMALS-1",
    "page": "Customize TimeArray printing",
    "title": "DECIMALS",
    "category": "section",
    "text": "DECIMALS = 4The default setting is 4. It shows values out to four decimal places:using TimeSeries\nusing MarketData\npercentchange(cl)You can change it to whatever value you prefer. If you change it to 6, the same transformation will display like this:julia> percentchange(cl)\n499x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-04 to 2001-12-31\n│            │ Close     │\n├────────────┼───────────┤\n│ 2000-01-04 │ -0.084331 │\n│ 2000-01-05 │ 0.014634  │\n│ 2000-01-06 │ -0.086538 │\n│ 2000-01-07 │ 0.047368  │\n│ 2000-01-10 │ -0.017588 │\n│ 2000-01-11 │ -0.051151 │\n│ 2000-01-12 │ -0.059946 │\n│ 2000-01-13 │ 0.109646  │\n│ 2000-01-14 │ 0.03814   │\n   ⋮\n│ 2001-12-19 │ 0.029034  │\n│ 2001-12-20 │ -0.043941 │\n│ 2001-12-21 │ 0.015965  │\n│ 2001-12-24 │ 0.017143  │\n│ 2001-12-26 │ 0.006086  │\n│ 2001-12-27 │ 0.026989  │\n│ 2001-12-28 │ 0.016312  │\n│ 2001-12-31 │ -0.023629 │"
},

{
    "location": "dotfile/#MISSING-1",
    "page": "Customize TimeArray printing",
    "title": "MISSING",
    "category": "section",
    "text": "This output is controlled with const values to accommodate difficult to remember unicode numbers:const NAN       = \"NaN\"\nconst NA        = \"NA\"\nconst BLACKHOLE = \"\\u2B24\"\nconst DOTCIRCLE = \"\\u25CC\"\nconst QUESTION  = \"\\u003F\"\n\nMISSING = NANThe default setting displays NaN, which represent the actual value when padding=true is selected for certain transformations. You can change it to show differently with the provided const values or roll your own. Dot files are often used to customize your experience, so have at it!Here is an example in REPL with the default:julia> lag(cl, padding=true)\n500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31\n│            │ Close  │\n├────────────┼────────┤\n│ 2000-01-03 │ NaN    │\n│ 2000-01-04 │ 111.94 │\n│ 2000-01-05 │ 102.5  │\n│ 2000-01-06 │ 104.0  │\n│ 2000-01-07 │ 95.0   │\n│ 2000-01-10 │ 99.5   │\n│ 2000-01-11 │ 97.75  │\n│ 2000-01-12 │ 92.75  │\n│ 2000-01-13 │ 87.19  │\n   ⋮\n│ 2001-12-19 │ 21.01  │\n│ 2001-12-20 │ 21.62  │\n│ 2001-12-21 │ 20.67  │\n│ 2001-12-24 │ 21.0   │\n│ 2001-12-26 │ 21.36  │\n│ 2001-12-27 │ 21.49  │\n│ 2001-12-28 │ 22.07  │\n│ 2001-12-31 │ 22.43  │Here is an example in REPL with NA selected:julia> lag(cl, padding=true)\n500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31\n│            │ Close  │\n├────────────┼────────┤\n│ 2000-01-03 │ NA     │\n│ 2000-01-04 │ 111.94 │\n│ 2000-01-05 │ 102.5  │\n│ 2000-01-06 │ 104.0  │\n│ 2000-01-07 │ 95.0   │\n│ 2000-01-10 │ 99.5   │\n│ 2000-01-11 │ 97.75  │\n│ 2000-01-12 │ 92.75  │\n│ 2000-01-13 │ 87.19  │\n   ⋮\n│ 2001-12-19 │ 21.01  │\n│ 2001-12-20 │ 21.62  │\n│ 2001-12-21 │ 20.67  │\n│ 2001-12-24 │ 21.0   │\n│ 2001-12-26 │ 21.36  │\n│ 2001-12-27 │ 21.49  │\n│ 2001-12-28 │ 22.07  │\n│ 2001-12-31 │ 22.43  │Here is an example in REPL with BLACKHOLE selected:julia> lag(cl, padding=true)\n500x1 TimeSeries.TimeArray{Float64,1,Date,Array{Float64,1}} 2000-01-03 to 2001-12-31\n│            │ Close  │\n├────────────┼────────┤\n│ 2000-01-03 │ ⬤     │\n│ 2000-01-04 │ 111.94 │\n│ 2000-01-05 │ 102.5  │\n│ 2000-01-06 │ 104.0  │\n│ 2000-01-07 │ 95.0   │\n│ 2000-01-10 │ 99.5   │\n│ 2000-01-11 │ 97.75  │\n│ 2000-01-12 │ 92.75  │\n│ 2000-01-13 │ 87.19  │\n   ⋮\n│ 2001-12-19 │ 21.01  │\n│ 2001-12-20 │ 21.62  │\n│ 2001-12-21 │ 20.67  │\n│ 2001-12-24 │ 21.0   │\n│ 2001-12-26 │ 21.36  │\n│ 2001-12-27 │ 21.49  │\n│ 2001-12-28 │ 22.07  │\n│ 2001-12-31 │ 22.43  │Other const values include DOTCIRCLE and QUESTION. The UNICORN value is a feature request."
},

{
    "location": "plotting/#",
    "page": "Plotting",
    "title": "Plotting",
    "category": "page",
    "text": ""
},

{
    "location": "plotting/#Plotting-1",
    "page": "Plotting",
    "title": "Plotting",
    "category": "section",
    "text": "TimeSeries defines a recipe that allows plotting to a number of different plotting packages using the Plots.jl framework (no plotting packages will be automatically installed by TimeSeries)."
},

{
    "location": "plotting/#plot-1",
    "page": "Plotting",
    "title": "plot",
    "category": "section",
    "text": "The recipe allows TimeArray objects to be passed as input to plot. The recipe will plot each variable as an individual line, aligning all variables to the same y axis (here shown using PyPlot as a plotting backend).using Plots, MarketData, TimeSeries\npyplot()\nplot(MarketData.ohlc)(Image: image)More sophisticated plots can be created by using keyword attributes and subsets:plot(MarketData.ohlc[:Low], seriestype = :scatter, markersize = 3, color = :red, markeralpha = 0.4, grid = true)(Image: image)A complete list of all attributes and plotting possibilities can be found in the Plots documentation.Plotting candlestick:plot(TimeSeries.Candlestick(MarketData.ohlc))(Image: image)"
},

]}
