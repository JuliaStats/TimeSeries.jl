function equity_curve(x)
  equity_curve = [ 1;  cumsum(diff(log(x["Close"]))) + 1];
end

