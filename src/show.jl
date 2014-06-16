###### show #####################
 
function show{T,N}(io::IO, ta::TimeArray{T,N})

  # variables 
  nrow          = size(ta.values, 1)
  ncol          = size(ta.values, 2)
  intcatcher    = falses(ncol)
  for c in 1:ncol
      rowcheck =  trunc(ta.values[:,c]) - ta.values[:,c] .== 0
      if sum(rowcheck) == length(rowcheck)
          intcatcher[c] = true
      end
  end
  spacetime     = strwidth(string(ta.timestamp[1])) + 3
  firstcolwidth = strwidth(ta.colnames[1])
  colwidth      = Int[]
      for m in 1:ncol
          T == Bool ?
          push!(colwidth, max(strwidth(ta.colnames[m]), 5)) :
          push!(colwidth, max(strwidth(ta.colnames[m]), strwidth(@sprintf("%.2f", maximum(ta.values[:,m]))) + DECIMALS - 2))
      end

  # summary line
  print(io, @sprintf("%dx%d %s %s to %s", nrow, ncol, typeof(ta), string(ta.timestamp[1]), string(ta.timestamp[nrow])))
  println(io, "")
  println(io, "")

  # row label line

   print(io, ^(" ", spacetime), ta.colnames[1], ^(" ", colwidth[1] + 2 -firstcolwidth))

   for p in 2:length(colwidth)
     print(io, ta.colnames[p], ^(" ", colwidth[p] - strwidth(ta.colnames[p]) + 2))
   end
   println(io, "")

  # timestamp and values line
    if nrow > 7
        for i in 1:4
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(iround(ta.values[i,j]), colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end

        println(io, '\u22EE')

        for i in nrow-3:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(iround(ta.values[i,j]), colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    else
        for i in 1:nrow
            print(io, ta.timestamp[i], " | ")
        for j in 1:ncol
            T == Bool ?
            print(io, rpad(ta.values[i,j], colwidth[j] + 2, " ")) :
            intcatcher[j] & SHOWINT ?
            print(io, rpad(iround(ta.values[i,j]), colwidth[j] + 2, " ")) :
            print(io, rpad(round(ta.values[i,j], DECIMALS), colwidth[j] + 2, " "))
        end
        println(io, "")
        end
    end
end
