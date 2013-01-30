#the whole problem is getting the function to return an Array of type other than ANY
#in which case the padNA should work as should the rest of the bang attachements


####### Array version

function devmoving(v::Array, f::Function, n::Integer)
  foo =  [f(v[i:i+(n-1)]) for i=1:length(v)-(n-1)]
end

################## not working refactor attempts ###########

function devmoving(dv::DataArray, f::Function, n::Integer)
  padNA(DataArray([f(dv[i:i+(n-1)]) for i=1:length(dv)-(n-1)]), n-1, 0)
end

function devmovingloop(dv::DataArray, f::Function, n::Integer)
  res = ones(length(dv)-(n-1))
  for i=1:length(dv)-(n-1)
    res[i] =  f(dv[i:i+(n-1)]) 
  end
  padNA(DataArray(res), n-1, 0)
end

function devmoving!(df::DataFrame, col::String, f::Function, n::Integer)
  new_col = strcat(string(f), "_", string(n))
  within!(df, quote
          $new_col = $devmovingloop($df[$col], $f, $n)
          end)
end
 
