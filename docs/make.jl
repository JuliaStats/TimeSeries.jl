using Documenter
using TimeSeries


makedocs(
    format = Documenter.HTML(),
    sitename = "TimeSeries.jl",
    modules = [TimeSeries],
    pages = [
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
        "dotfile.md",
        "plotting.md",
    ]
)

deploydocs(
    repo         = "github.com/JuliaStats/TimeSeries.jl.git",
    devbranch    = "master",
    push_preview = true,
)
