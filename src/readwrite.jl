###### readtimearray ############

function readtimearray(fname::AbstractString; meta=nothing, format::AbstractString="")
    cfile = readcsv(fname)
    
    # remove empty lines if any
    inoempty = find(s -> length(s) > 2, cfile[:,1])
    cfile = cfile[inoempty,:]
    
    time  = cfile[2:end,1]
    if length(time[1]) < 11
        # assuming Date not DateTime
        format == "" ?
        tstamps = Date[Date(t) for t in time] :
        tstamps = Date[Date(t, format) for t in time]
    else
        format == "" ?
        tstamps = DateTime[DateTime(t) for t in time] :
        tstamps = DateTime[DateTime(t, format) for t in time]
    end 

    vals   = insertNaN(cfile[2:end, 2:end])
    cnames = UTF8String[]
    for c in cfile[1, 2:end]
        push!(cnames, c)
    end
    TimeArray(tstamps, vals, cnames, meta)
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
