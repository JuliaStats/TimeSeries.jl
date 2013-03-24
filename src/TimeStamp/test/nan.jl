test_array  =  [NaN, 0.248854, 0.808243, 0.380405, 0.528888, 0.714294, 0.689547, 0.414978, 0.671928, 0.953197, 0.0316208]

@assert 10                   == length(removeNaN(test_array)) 
@assert 0.953197             == nanmax(test_array) 
@assert 0.0316208            == nanmin(test_array) 
@assert 5.4419548            == nansum(test_array) 
@assert 0.5441954800000001   == nanmean(test_array) 
@assert 0.600408             == nanmedian(test_array) 
@assert 0.07745529928048178  == nanvar(test_array) 
@assert 0.2783079216991169   == nanstd(test_array) 
@assert -0.38077408541675095 == nanskewness(test_array) 
@assert -0.6946034443391493  == nankurtosis(test_array) 

