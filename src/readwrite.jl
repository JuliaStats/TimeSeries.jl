###### readtimearray ############

function readtimearray(fname::String)
    cfile = readcsv(fname)
    time  = cfile[2:end,1]

    length(time[1]) < 11 ?
    tstamps = Date[Date(t) for t in time] :
    tstamps = DateTime[DateTime(t) for t in time] 

    vals   = insertNaN(cfile[2:end, 2:end])
    cnames = UTF8String[]
    for c in cfile[1, 2:end]
        push!(cnames, c)
    end
    TimeArray(tstamps, vals, cnames)
end

function insertNaN{N}(aa::Array{Any,N})
    for i in 1:size(aa,1)
        for j in 1:size(aa,2)
            if !isa(aa[i,j], Real)
                aa[i,j] = NaN
            end
        end
    end
    convert(Array{Float64,N},aa)
end
