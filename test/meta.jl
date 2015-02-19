cll = TimeArray(cl.timestamp, cl.values, cl.colnames, "AAPL")

facts("construction with and without meta field") do

    context("default meta field to Nothing") do
        @fact cl.meta    => Void
        @pending cl.meta => Nothing
    end

    context("allow typed objects in meta field") do
        @fact cll.meta => "AAPL"
    end
end
