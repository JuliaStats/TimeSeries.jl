using Calendar

a = TimeStamp[]
b = TimeStamp[]

for i in 1:10
  newa = TimeStamp(p("2012-12-29")+days(i), i)
  push!(a, newa)
end

for i in 1:10
  newa = TimeStamp(p("2012-12-29")+days(i), i+.5)
  push!(b, newa)
end

c  =  [NaN, 0.248854, 0.808243, 0.380405, 0.528888, 0.714294, 0.689547, 0.414978, 0.671928, 0.953197, 0.0316208]

###################################################################
###### head, tail #################################################
###################################################################

a_head  = head(a)
a_tail  = tail(a)
a_first = first(a)
a_last  = last(a)

@assert 6  == a_head[6].value
@assert 10 == a_tail[6].value
@assert 1  == a_first[1].value
@assert 10 == a_last[1].value

###################################################################
###### rows #######################################################
###################################################################

gt_a = gtrows(a, 5)
lt_a = ltrows(a, 5)
et_a = etrows(a, 5)

@assert 6 == gt_a[1].value
@assert 4 == lt_a[4].value
@assert 5 == et_a[1].value


###################################################################
###### by date ####################################################
###################################################################

day_a       = stamp(byday(a,1))
month_a     = stamp(bymonth(a,1))
year_a      = stamp(byyear(a,2013))
week_a      = stamp(byweek(a,2))
dayofweek_a = stamp(bydayofweek(a,1))
dayofyear_a = stamp(bydayofyear(a,7))
# hour_a    = stamp(byhour(a,1))
# minute_a  = stamp(byminute(a,1))
# second_a  = stamp(bysecond(a,1))

@assert [p("2013-01-01")]    == day_a
@assert p("2013-01-02")    == month_a[2]
@assert p("2013-01-03")    == year_a[3]
@assert p("2013-01-06")    == week_a[1]
@assert p("2013-01-06")    == dayofweek_a[2]
@assert p("2013-01-07")    == dayofyear_a[1]
# @assert [p("2013-01-01")]  == hour_a
# @assert [p("2013-01-01")]  == minute_a
# @assert [p("2013-01-01")]  == second_a

###################################################################
###### 2-Array ops ################################################
###################################################################

sumsab = sums(a,b)
diffsab = diffs(a,b)
divsab  = divs(a,b)
multsab = mults(a,b)

@assert 2.5  == val(sumsab)[1]
@assert -0.5 == val(diffsab)[1]
@assert 0.8  == val(divsab)[2]
@assert 105  == val(multsab)[10]



###################################################################
###### NaN ########################################################
###################################################################

@assert 10                   == length(removeNaN(c)) 
@assert 5.4419548            == nansum(c) 
@assert 0.5441954800000001   == nanmean(c) 
@assert 0.600408             == nanmedian(c) 
@assert 0.07745529928048178  == nanvar(c) 
@assert 0.2783079216991169   == nanstd(c) 
@assert -0.38077408541675095 == nanskewness(c) 
@assert -0.6946034443391493  == nankurtosis(c) 
















