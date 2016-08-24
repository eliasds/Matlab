function S = roundp(val,p)
% Usage: S = roundp(val,p)
%
% Rounds the value to a fixed number of digits, p, beyond which all digits
% are considered zeros.
% Ex: roundp(0.004239, 2) = 4.2e-3
%     roundp(42.39, 1) = 40.00

int10 = ceil(log10(val));
int10(find(val==0)) = 0;
S = round(val/10^int10*10^p)/10^p*10^int10;