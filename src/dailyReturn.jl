function daily_return(x)

  logReturn    = diff(log(x))
  simpleReturn = expm1(logReturn) 
  RET          = [0 ; simpleReturn]
  ret          = [0 ; logReturn]
                  
#  if n == "log"
#    ret
#  else
#    RET
#  end
RET
  
end


