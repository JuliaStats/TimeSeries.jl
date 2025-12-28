###### readtimearray ############

"""
    readtimearray(source; delim=',', meta=nothing, format="", header=true)

Read a delimited file into a `TimeArray`.

The first column is treated as timestamps. Empty or non-numeric cells in data columns
are converted to `NaN`. Date vs DateTime is inferred from timestamp length (< 11 characters
assumes Date, otherwise DateTime).

# Arguments

  - `source`: File path or IO stream
  - `delim::Char`: Delimiter character (default: `','`)
  - `meta`: Metadata to attach to the `TimeArray` (default: `nothing`)
  - `format::AbstractString`: Date format string (default: `""` for automatic detection)
  - `header::Bool`: Whether the file has a header row (default: `true`)

# Examples

```julia
readtimearray("data.csv")
readtimearray("data.csv"; delim='\t', format="yyyy-mm-dd")
```
"""
function readtimearray(
    source; delim::Char=',', meta=nothing, format::AbstractString="", header::Bool=true
)
    cfile = readdlm(source, delim; header=header)
    if header
        cfile, hd = cfile
    end

    # remove empty lines if any
    inoempty = findall(s -> length(s) > 2, cfile[:, 1])
    cfile = cfile[inoempty, :]

    # create a DataFormat instance to improve performance
    df = isempty(format) ? nothing : DateFormat(format)

    time = cfile[1:end, 1]
    if length(time[1]) < 11
        # assuming Date not DateTime
        tstamps =
            df === nothing ? Date[Date(t) for t in time] : Date[Date(t, df) for t in time]
    else
        tstamps = if df === nothing
            DateTime[DateTime(t) for t in time]
        else
            DateTime[DateTime(t, df) for t in time]
        end
    end

    vals = insertNaN(cfile[1:end, 2:end])
    cnames = header ? Symbol.(hd[2:end]) : gen_colnames(size(cfile, 2) - 1)
    return TimeArray(tstamps, vals, cnames, meta)
end  # readtimearray

function insertNaN(aa::Array{Any,N}) where {N}
    for i in 1:size(aa, 1)
        for j in 1:size(aa, 2)
            if !isa(aa[i, j], Real)
                aa[i, j] = NaN
            end
        end
    end
    return convert(Array{Float64,N}, aa)
end

"""
    writetimearray(ta::TimeArray, fname::AbstractString; delim=',', format="", header=true)

Write a `TimeArray` to a delimited file.

# Arguments

  - `ta::TimeArray`: Time array to write
  - `fname::AbstractString`: Output file path
  - `delim::Char`: Delimiter character (default: `','`)
  - `format::AbstractString`: Date format string (default: `""` for default formatting)
  - `header::Bool`: Whether to write a header row (default: `true`)

# Examples

```julia
writetimearray(ta, "output.csv")
writetimearray(ta, "output.tsv"; delim='\t', format="yyyy-mm-dd")
```
"""
function writetimearray(
    ta::TimeArray,
    fname::AbstractString;
    delim::Char=',',
    format::AbstractString="",
    header::Bool=true,
)
    open(fname, "w") do io
        if header
            strvals = join(colnames(ta), delim)
            write(io, string("Timestamp", delim, strvals, "\n"))
        end

        for i in eachindex(timestamp(ta))
            strvals = replace(join(values(ta)[i, :], delim), "NaN" => "")
            strtstamp = if isempty(format)
                string(timestamp(ta)[i])
            else
                Dates.format(timestamp(ta)[i], format)
            end
            write(io, string(strtstamp, delim, strvals, "\n"))
        end
    end
end  # writetimearray
