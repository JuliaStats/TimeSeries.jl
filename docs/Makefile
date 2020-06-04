all:
	julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.develop(PackageSpec(path=joinpath(pwd(), "..")))'
	julia --project=. --color=yes make.jl
