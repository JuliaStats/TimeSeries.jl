macro timeseries()
  println("")
  reload(Pkg.dir("TimeSeries/test/runtests.jl"))
end

########### time trial wrapper #####################################

function timetrial(f::Function, v::Any, n::Int)
  p = Float64[]
  for i in 1:n+1
    push!(p, @elapsed f(v))
  end
  mean(p[2:end]) # toss out the first execution from the average
end
