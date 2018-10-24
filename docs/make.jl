using Documenter
using TimeSeries


makedocs(
    format = :html,
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
        "dotfile.md",
        "plotting.md",
    ]
)

deploydocs(
    repo = "github.com/JuliaStats/TimeSeries.jl.git",
    julia  = "1.0",
    latest = "master",
    target = "build",
    deps = nothing,  # we use the `format = :html`, without `mkdocs`
    make = nothing,  # we use the `format = :html`, without `mkdocs`
)
