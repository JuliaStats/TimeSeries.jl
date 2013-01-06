#this is the generic for rolling window of a specified statistical
#moment. Below is the algorithm implemented for the four moments.

function moving_mean(x,n)
   foo = [mean(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function moving_var(x,n)
   foo = [var(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function moving_skewness(x,n)
   foo = [skewness(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end

function moving_kurtosis(x,n)
   foo = [kurtosis(x[i:i+(n-1)]) for i=1:length(x)-(n-1)]
end
