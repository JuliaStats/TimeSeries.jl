using Documenter
using TimeSeries

makedocs(;
    format=Documenter.HTML(; prettyurls=(get(ENV, "CI", nothing) == "true")),
    sitename="TimeSeries.jl",
    modules=[TimeSeries],
    warnonly=true, # some docstrings are not in the manual
    pages=[
        "index.md",
        "getting_started.md",
        "timearray.md",
        "indexing.md",
        "split.md",
        "modify.md",
        "operators.md",
        "apply.md",
        "combine.md",
        "readwrite.md",
        "tables.md",
        "plotting.md",
        "retime.md",
        "api.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaStats/TimeSeries.jl.git", devbranch="master", push_preview=true
)
