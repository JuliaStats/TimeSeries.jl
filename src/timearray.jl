type TimeArray{T,N}
  index::Array{Date{ISOCalendar},1}
  values::Array{T,N}
  # colnames::{Dict}
end
