### shortcut to extracting out the fields from Array{TimeStamp}

v(x) = [v.value for v in x]
t(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)
