###### readtimearray ############

function readtimearray(fname::String)
    blob    = readcsv(fname)
    tstamps = Date[Date(i) for i in blob[2:end, 1]]
    vals    = insertNaN(blob[2:end, 2:end])
    cnames  = UTF8String[]
    for b in blob[1, 2:end]
        push!(cnames, b)
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
