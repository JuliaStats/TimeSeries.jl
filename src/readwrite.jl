###### readtimearray ############

# TimeCols=	1: default, date and time are together in 1 column
#			0: date and time are in 1 column in Unix time format
#			2: date and time are in 2 separate columns
#			3: date is in yyymmdd format, where yyy is counted from 1900

function readtimearray(fname::String; TimeCols=1)
    blob = readcsv(fname)
    ValColbegin = 2
	ValRowBegin = 2
    if (isa(blob[1,1], Number)) 
	    ValRowBegin = 1
	end
		
    if (TimeCols==1) # date and time are together in 1 column
    	tstamps = Date{ISOCalendar}[date(i) for i in blob[ValRowBegin:end, 1]]
	elseif (TimeCols==0) # date and time are in 1 column in Unix time format
    	tstamps = Date{ISOCalendar}[unix2datetime(1000*int64(blob[i, 1]), UTC) 
    				for i in ValRowBegin:endof(blob[:,1])]
    elseif (TimeCols==2)  # date and time are in 2 separate columns
    	tstamps = Date{ISOCalendar}[]
    	for i in ValRowBegin:length(blob[:, 1])
    		ymd = date(blob[i, 1])
    		s = blob[i, 2]
    		m = match(r"[|\-|\:|\s]",s)
    		hh,mm,ss = split(s,m.match)
    		push!(tstamps, datetime(year(ymd), month(ymd), day(ymd), int(hh), int(mm), int(ss)))
    	end
    	ValColbegin = 3
    elseif (TimeCols==3) # date is in yyymmdd format, where yyy is counted from 1900
    	tstamps = Date{ISOCalendar}[]
    	for i in ValRowBegin:length(blob[:, 1])
    		num = string(int(blob[i, 1]))
    		yy = string(int(num[1:end-4])+1900)
    		mm = num[end-3 : end-2]
    		dd = num[end-1 : end]
    		ts = date(int(yy), int(mm), int(dd))
    		if (findfirst(tstamps, ts) != 0) 
    			println(ts, " date already exists")
    		end
    		push!(tstamps, ts)
    	end
    end
    vals    = insertNaN(blob[ValRowBegin:end, ValColbegin:end])
    cnames  = ASCIIString[]
    if (ValRowBegin>1) 
		for b in blob[1, ValColbegin:end]
		    push!(cnames, b)
		end
    else 
 		for i in 1:length(blob[1, ValColbegin:end])
		    push!(cnames, string(i))
		end
	end   	
    TimeArray(tstamps, vals, cnames)
end

function insertNaN{T, N}(aa::Array{T,N})
    for i in 1:size(aa,1)
        for j in 1:size(aa,2)
            if !isa(aa[i,j], Real)
                aa[i,j] = NaN
            end
        end
    end
    float(aa)
end
