function Y = roundp( X, N )
%roundp: round with precision
%   Rounds the value X to Nth decimal place
%   X: input value
%   N: number of decimal places
%   Ex: roundp(0.004239, 2) = 4.2e-3
%       roundp(42.39, 1) = 40.00

Y = round(X*10^N)/10^N;

end

