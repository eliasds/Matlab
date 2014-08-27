function [ theta_r ] = thetaround( theta, digit )
%thetaround approximate the theta up to "digit" decimal digits in degree
%   theta: input data, in radians
%   digit: number of digit

theta_r = round(theta*10^digit)/10^digit;

end

