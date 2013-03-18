#################### alignment

alignment(x::Any) = (0, length(sprint(showcompact, x)))
alignment(x::Number) = (length(sprint(showcompact, x)), 0)
alignment(x::Integer) = (length(sprint(showcompact, x)), 0)

function alignment(x::Real)
    m = match(r"^(.*?)((?:[\.eE].*)?)$", sprint(showcompact, x))
    m == nothing ? (length(sprint(showcompact, x)), 0) :
                   (length(m.captures[1]), length(m.captures[2]))
end

function alignment(x::Complex)
    m = match(r"^(.*,)(.*)$", sprint(showcompact, x))
    m == nothing ? (length(sprint(showcompact, x)), 0) :
                   (length(m.captures[1]), length(m.captures[2]))
end

function alignment(x::Rational)
    m = match(r"^(.*?/)(/.*)$", sprint(showcompact, x))
    m == nothing ? (length(sprint(showcompact, x)), 0) :
                   (length(m.captures[1]), length(m.captures[2]))
end

const undef_ref_str = "#undef"
const undef_ref_alignment = (3,3)

function alignment( X::AbstractMatrix,
                    rows::AbstractVector, cols::AbstractVector,
                    cols_if_complete::Integer, cols_otherwise::Integer, 
                    sep::Integer)
    a = {}
    for j in cols
        l = r = 0
        for i in rows
            if isassigned(X,i,j)
                aij = alignment(X[i,j])
            else
                aij = undef_ref_alignment
            end
            l = max(l, aij[1])
            r = max(r, aij[2])
        end
        push!(a, (l, r))
        if length(a) > 1 && sum(map(sum,a)) + sep*length(a) >= cols_if_complete
            pop!(a)
            break
        end
    end
    if 1 < length(a) < size(X,2)
        while sum(map(sum,a)) + sep*length(a) >= cols_otherwise
            pop!(a)
        end
    end
    return a
end


############# print_TimeArray

function print_TimeArray(io::IO,
                      X::AbstractMatrix, rows::Integer, cols::Integer,
                      pre::String, sep::String, post::String,
                      hdots::String, vdots::String, ddots::String,
                      hmod::Integer, vmod::Integer)

  cols -= length(pre) + length(post)
  presp = repeat(" ", length(pre))
  postsp = ""
  @assert strwidth(hdots) == strwidth(ddots)
  ss = length(sep)
  m, n = size(X)
  if m <= rows # rows fit
      A = alignment(X,1:m,1:n,cols,cols,ss)
      if n <= length(A) # rows and cols fit
          for i = 1:m
              print(io, i == 1 ? pre : presp)
              print_matrix_row(io, X,A,i,1:n,sep)
              print(io, i == m ? post : postsp)
              if i != m; println(io, ); end
          end
      else # rows fit, cols don't
          c = div(cols-length(hdots)+1,2)+1
          R = reverse(alignment(X,1:m,n:-1:1,c,c,ss))
          c = cols - sum(map(sum,R)) - (length(R)-1)*ss - length(hdots)
          L = alignment(X,1:m,1:n,c,c,ss)
          for i = 1:m
              print(io, i == 1 ? pre : presp)
              print_matrix_row(io, X,L,i,1:length(L),sep)
              print(io, i % hmod == 1 ? hdots : repeat(" ", length(hdots)))
              print_matrix_row(io, X,R,i,n-length(R)+1:n,sep)
              print(io, i == m ? post : postsp)
              if i != m; println(io, ); end
          end
      end
  else # rows don't fit
       t = div(rows,2)
       I = [1:t; m-div(rows-1,2)+1:m]
                    A = alignment(X,I,1:n,cols,cols,ss)
                             if n <= length(A) # rows don't fit, cols do
                                         for i in I
                                                         print(io, i == 1 ? pre : presp)
                                                                         print_matrix_row(io, X,A,i,1:n,sep)
                                                                                         print(io, i == m ? post : postsp)
                                                                                                         if i != I[end]; println(io, ); end
                                                                                                                         if i == t
                                                                                                                                             print(io, i == 1 ? pre : presp)
                                                                                                                                                                 print_matrix_vdots(io, vdots,A,sep,vmod,1)
                                                                                                                                                                                     println(io, i == m ? post : postsp)
                                                                                                                                                                                                     end
                                                                                                                                                                                                                 end
                                                                                                                                                                                                                         else # neither rows nor cols fit
                                                                                                                                                                                                                                     c = div(cols-length(hdots)+1,2)+1
                                                                                                                                                                                                                                                 R = reverse(alignment(X,I,n:-1:1,c,c,ss))
                                                                                                                                                                                                                                                             c = cols - sum(map(sum,R)) - (length(R)-1)*ss - length(hdots)
                                                                                                                                                                                                                                                                         L = alignment(X,I,1:n,c,c,ss)
                                                                                                                                                                                                                                                                                     r = mod((length(R)-n+1),vmod)
                                                                                                                                                                                                                                                                                                 for i in I
                                                                                                                                                                                                                                                                                                                 print(io, i == 1 ? pre : presp)
                                                                                                                                                                                                                                                                                                                                 print_matrix_row(io, X,L,i,1:length(L),sep)
                                                                                                                                                                                                                                                                                                                                                 print(io, i % hmod == 1 ? hdots : repeat(" ", length(hdots)))
                                                                                                                                                                                                                                                                                                                                                                 print_matrix_row(io, X,R,i,n-length(R)+1:n,sep)
                                                                                                                                                                                                                                                                                                                                                                                 print(io, i == m ? post : postsp)
                                                                                                                                                                                                                                                                                                                                                                                                 if i != I[end]; println(io, ); end
                                                                                                                                                                                                                                                                                                                                                                                                                 if i == t
                                                                                                                                                                                                                                                                                                                                                                                                                                     print(io, i == 1 ? pre : presp)
                                                                                                                                                                                                                                                                                                                                                                                                                                                         print_matrix_vdots(io, vdots,L,sep,vmod,1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                             print(io, ddots)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 print_matrix_vdots(io, vdots,R,sep,vmod,r)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     println(io, i == m ? post : postsp)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             print_matrix(io::IO, X::AbstractMatrix, rows::Integer, cols::Integer) =
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 print_matrix(io, X, rows, cols, " ", "  ", "",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   "  \u2026  ", "\u22ee", "  \u22f1  ", 5, 5)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 print_matrix(io::IO, X::AbstractMatrix) = print_matrix(io, X, tty_rows()-4, tty_cols())
