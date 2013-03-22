### shortcut to extracting out the fields from Array{TimeStamp}

# function v(x::Array{TimeStamp}, s::String) 
#   nest = string("v.value.", s)
#   arr  = [nest for v in x]
# end

v(x) = [v.value for v in x]
t(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)
