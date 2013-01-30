function upto(v::Array, f::Function)
  [f(v[1:i]) for i=1:length(v)]
end

function upto(dv::DataArray, f::Function)
  [f(dv[1:i]) for i=1:length(dv)]
end

function upto!(df::DataFrame, col::String, f::Function)
  new_col = strcat(string(f), "_upto")
  within!(df, quote
         $new_col  = $upto($df[$col], $f)
         end)
end
 
