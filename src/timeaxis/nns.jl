###############################################################################
#  Types
###############################################################################

struct NearestNeighbors{D,C,R}
    k::Int
    c::C  # centroid
    r::R  # radius
end

function NearestNeighbors(k::Integer, c::C, r::R, d::Symbol) where {C,R}
    (d ∉ (:both, :forward, :backward)) && throw(ArgumentError("invalid direction: $d"))
    NearestNeighbors{d,C,R}(k, c, r)
end

nns(; k = 1, c = nothing, radius, direction = :both) =
    NearestNeighbors(k, c, radius, direction)
