
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




function lead_array(x::Array, n::Int64)
  if typeof(x) == DataArray{Float64,1}
    laggard = nas(DataVector[1.], length(x)) 
  else
    laggard = nas(DataVector[1], length(x)) 
  end
  [laggard[i] = x[i+n]  for i=1:length(x)-n]
  laggard
end
