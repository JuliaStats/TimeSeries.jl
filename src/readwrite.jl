###### readtimearray ############

function readtimearray(source; delim::Char = ',', meta = nothing,
                       format::AbstractString = "", header::Bool = true)
    cfile = readdlm(source, delim, header = header)
    if header
        cfile, hd = cfile
    end

    # remove empty lines if any
    inoempty = findall(s -> length(s) > 2, cfile[:, 1])
    cfile = cfile[inoempty, :]

    time = cfile[1:end, 1]
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

    vals   = insertNaN(cfile[1:end, 2:end])
    cnames = header ? Symbol.(hd[2:end]) : gen_colnames(size(cfile, 2) - 1)
    TimeArray(tstamps, vals, cnames, meta)
end  # readtimearray

function insertNaN(aa::Array{Any, N}) where {N}
    for i in 1:size(aa, 1)
        for j in 1:size(aa, 2)
            if !isa(aa[i, j], Real)
                aa[i, j] = NaN
            end
        end
    end
    convert(Array{Float64, N}, aa)
end

function writetimearray(ta::TimeArray, fname::AbstractString)

    open(fname, "w") do io

        strvals = join(colnames(ta), ",")
        write(io, string("Timestamp,", strvals, "\n"))

        for i in eachindex(timestamp(ta))
            strvals = replace(join(values(ta)[i, :], ","), "NaN" => "")
            write(io, string(timestamp(ta)[i], ",", strvals, "\n"))
        end  # for

    end

end  # writetimearray
