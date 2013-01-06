
function lead1(x)
  tmp = ones(length(x)-1)
  leader = [tmp[i] = x[i+1]  for i=1:length(x)-1]
  padded_leader = [float(leader) ;  nas(DataVector[float(n)], 1)  ]
end

######## function lead1(x)
########   tmp = ones(length(x))
########   leader = [tmp[i] = x[i+1]  for i=1:length(x)]
######## #  padded_leader = [nas(DataVector[float(n)], 1) ; float(leader)]
######## end
function leadn(x, n)
  tmp = ones(length(x)-n)
  leader = [tmp[i] = x[i+n]  for i=1:length(x)-n]
# NA padding here
end


function lag1(x)
  tmp = ones(length(x))
  laggard = [tmp[i] = x[i-1]  for i=2:length(x)]
  padded_laggard = [nas(DataVector[float(n)], 1)  ; float(laggard)]
end

function lagn(x, n)
  tmp = ones(length(x))
  laggard = [tmp[i] = x[i-n]  for i=(n+1):length(x)]
  padded_laggard = [nas(DataVector[float(n)], n)  ; float(laggard)]
# NA padding here
end
