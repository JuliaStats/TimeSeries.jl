
function tothis(dv::DataArray, f::Function)
  [f(dv[1:i]) for i=1:length(dv)]
end

function upto(df::DataFrame, col::String, f::Function)
  with(df, quote
       $tothis($df[$col], $f)
       end)
end

function upto!(df::DataFrame, col::String, f::Function)
  new_col = strcat(string(f), "_upto")
  within!(df, quote
         $new_col  = $tothis($df[$col], $f)
         end)
end
 
