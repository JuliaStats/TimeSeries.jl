function equity_curve(x)
  e_curve = [ 1;  cumsum(diff(log(x["Close"]))) + 1];
end

