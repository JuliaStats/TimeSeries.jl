# Public API Reference

This page lists all public functions and types exported by TimeSeries.jl.

```@autodocs
Modules = [TimeSeries]
Private = false
```

## Base Method Extensions

TimeSeries.jl extends several Base methods to work with `TimeArray` objects:

```@docs
Base.hcat(::TimeArray, ::TimeArray)
Base.hcat(::TimeArray, ::TimeArray, ::Vararg{TimeArray})
Base.vcat(::TimeArray...)
Base.map
Base.split(::TimeSeries.TimeArray, ::Function)
Base.:+
Base.:-
Base.:(==)
Base.eachrow
Base.eachcol
```