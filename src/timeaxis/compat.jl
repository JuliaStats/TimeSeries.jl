@static if VERSION < v"1.1"
    isnothing(::Any)     = false
    isnothing(::Nothing) = true
end
