#this is the generalized version

function mvg(x, f, n::Int64)
   foo = [f(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

