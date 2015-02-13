n = TimeArray(Date(12,12,2012), 12, ["twelve"])
t = TimeArray(Date(12,12,2012), 12, ["twelve"], 12.0)

facts("construction with and without meta field") do

    context("default meta field to Nothing") do
        @fact typeof(n.meta) => Nothing
    end

    context("allow typed objects in meta field") do
        @fact typeof(t.meta) => Float64
    end
end
