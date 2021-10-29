module TimeSeries

# stdlib
using Dates
using DelimitedFiles
using Statistics
# third-party
using DataStructures
using DocStringExtensions: SIGNATURES
using PaddedViews
using RecipesBase
using Reexport
using Tables

export TimeArray, AbstractTimeSeries,
       when, from, to, findwhen, timestamp, values, colnames, meta, head, tail,
       lag, lead, diff, percentchange, moving, upto,
       uniformspaced, uniformspace, dropnan,
       basecall,
       merge, collapse,
       readtimearray, writetimearray

# modify.jl
export rename, rename!

# timetable.jl
export TimeTable

###############################################################################
#  Submodule
###############################################################################

include("timeaxis/TimeAxis.jl")
@reexport using .TimeAxis

###############################################################################
#  include
###############################################################################

include(".timeseriesrc.jl")
include("ats.jl")
include("timearray.jl")
include("timetable.jl")
include("utilities.jl")
include("tables.jl")
include("split.jl")
include("apply.jl")
include("broadcast.jl")
include("combine.jl")
include("readwrite.jl")
include("modify.jl")
include("basemisc.jl")
include("deprecated.jl")
include("plotrecipes.jl")

###############################################################################
#  reexport
###############################################################################

@reexport using Dates

end  # module TimeSeries
