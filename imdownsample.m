function [ output ] = imdownsample( img, bits, minval, maxval )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% 


orig_minval = min(img(:));
orig_maxval = max(img(:));


if nargin <= 2
    minval = orig_minval;
    maxval = orig_maxval;
end

if nargin == 1
    bits = 8;
end


img(img < minval) = minval;
img(img > maxval) = maxval;
    
output = (img - minval)/(maxval - minval);
output = output * (2^bits - 1);
output = round(output);
output = output / (2^bits - 1);
output = output*(maxval - minval) + minval;

