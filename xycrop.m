function [ matcrop, rect ] = xycrop( mat, rect )
%Crops the XY component of either a 2D image or a 3D matrix
%
%   xycrop crops the XY component of either a 2D image or a 3D matrix
%   using the more natural cropping rectangle of [xi, yi, xdelta, ydelta]
%   where:
%   xi = first x pixel in cropbox
%   yi = first y pixel in cropbox
%   xdelta = number of pixels you want to keep in the x direction
%   ydelta = number of pixels you want to keep in the y direction
%   

% matsize = size(mat);
% Is this a 2D or 3D matrix?
matdims = ndims(mat);

% Tells matlab that you actually want to crop x pixels, not x+1 pixels
rect(3:4) = rect(3:4)-1;

if matdims == 3
    matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)),:);
elseif matdims == 2
    matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)));
else
    error('Matrix Must Have 2 or 3 Dimensions')
end

end
