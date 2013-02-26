
##############################################################################
##
## Extend methods in Base by default
##
##############################################################################

importall Base
importall Stats

##############################################################################
##
## AbstractSeries 
##
##############################################################################

abstract AbstractSeries <: Associative{String, Any}

##############################################################################


type Series <: AbstractSeries
  values::DataFrame
  idx::IndexedVector{CalendarTime}
end

isempty(ts::AbstractSeries) = ncol(ts) == 0


nrow(ts::Series) = ncol(ts) > 0 ? length(ts.columns[1]) : 0
ncol(ts::Series) = length(ts.idx)
