function [ matcrop, rect ] = xycropcenter( mat, rect )
%Crops the XY component of either a 2D image or a 3D matrix from center
%
%   xycropcenter crops the XY component of either a 2D image or a 3D matrix
%   using the more natural cropping rectangle of [xi, yi, xdelta, ydelta]
%   where:
%   xi = center x pixel in cropbox
%   yi = center y pixel in cropbox
%   xdelta = number of pixels you want to keep in the x direction
%   ydelta = number of pixels you want to keep in the y direction
%   

% matsize = size(mat);
% Is this a 2D or 3D matrix?
matdims = ndims(mat);

% Tells matlab that you actually want to crop x pixels, not x+1 pixels
% rect(3:4) = rect(3:4)-1;

xi = rect(1);
yi = rect(2);
xdelta = round(rect(3));
ydelta = round(rect(4));

if xdelta/2 > xi
    error('Center X coordinate is too close to the edge for your cropped dimentions')
end
if ydelta/2 > yi
    error('Center Y coordinate is too close to the edge for your cropped dimentions')
end

rect(1) = rect(1)+1-rect(3)/2;
rect(2) = rect(2)+1-rect(4)/2;

[ matcrop ] = xycrop( mat, rect );

% if matdims == 3
%     matcrop = mat((yi+1-ydelta/2):(yi+ydelta/2),(xi+1-xdelta/2):(xi+xdelta/2),:);
% %     matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)),:);
% elseif matdims == 2
%     matcrop = mat((yi+1-ydelta/2):(yi+ydelta/2),(xi+1-xdelta/2):(xi+xdelta/2));
% %     matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)));
% else
%     error('Matrix Must Have 2 or 3 Dimensions')
% end

end
