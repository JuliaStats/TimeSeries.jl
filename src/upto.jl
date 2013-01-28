
function tothis(x::DataArray,f::Function)
  [f(x[1:i]) for i=1:length(x)]
end

function upto(df::DataFrame, col::ASCIIString, f::Function)
  with(df, quote
       $tothis($df[$col], $f)
       end);
end

function upto!(df::DataFrame, col::ASCIIString, f::Function)
  newcol = strcat(string(f), "_upto")
  within!(df, quote
         $newcol  = $tothis($df[$col], $f)
        end);
end
 
