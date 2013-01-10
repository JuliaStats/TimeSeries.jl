const recipe = "read_stock"

macro taste(ex::Symbol)
  println("")
  reload(strcat(".julia/Thyme/test/", :($ex), ".jl"))
end


macro smell(food)
 :($food ? 
 println("\33[32mfresh\033[0m ")  :
 println("\33[31mrotten\033[0m "))
end
