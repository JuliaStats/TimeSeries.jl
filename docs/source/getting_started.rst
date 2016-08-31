Getting Started
==============

TimeSeries is a registered package. To add it to your Julia packages, simply do the following in
REPL::

    Pkg.add("TimeSeries")

Throughout this tutorial, we'll be using historical financial data sets, which are made available in the
``MarketData`` package. MarketData is also registered and can be added::

    Pkg.add("MarketData")

To create dummy data without using the ``MarketData`` package, simply use the following code block::

    dates  = collect(Date(1999,1,1):Date(2000,12,31))
    mytime = TimeArray(dates, rand(length(dates)))
