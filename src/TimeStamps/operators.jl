### shortcut to extracting out the fields from Array{TimeStamp}

# function v(x::Array{TimeStamp}, s::String) 
#   nest = string("v.value.", s)
#   arr  = [nest for v in x]
# end

# gah, I'm too lazy to figure out the generalized version

vopen(x) = [v.value.Open for v in x]
vhigh(x) = [v.value.High for v in x]
vlow(x) = [v.value.Low for v in x]
vclose(x) = [v.value.Close for v in x]
vvolume(x) = [v.value.Volume for v in x]
vadj(x) = [v.value.Adj for v in x]

# alias trick 

const Op = vopen
const Hi = vhigh
const Lo = vlow
const Cl = vclose
const Vo = vvolume
const Ad = vadj

v(x) = [v.value for v in x]
t(x) = [t.timestamp for t in x]


### shortcut for passing in date via a string for indexing

p(x::String) = Calendar.parse("yyyy-MM-dd", x)
