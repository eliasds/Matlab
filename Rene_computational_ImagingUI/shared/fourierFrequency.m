function [ f ] = fourierFrequency( sz, ps, dimension )
%FOURIERFREQUENCY Summary of this function goes here
%   Detailed explanation goes here

if length(sz) == 1
    sz = [sz, sz] ;
end
if length(ps) == 1
    ps = [ps, ps] ;
end

[xx, yy] = meshgrid(((-sz(1)/2):(sz(1)/2-1)) / (sz(1) * ps(1)), ...
                    ((-sz(2)/2):(sz(2)/2-1)) / (sz(2) * ps(2))) ;
switch (dimension)
    case 'x'
        f = xx ;
    case 'y'
        f = yy ;
    case 'r'
        f = sqrt(xx.^2 + yy.^2) ;
end

end

