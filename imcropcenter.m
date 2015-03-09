function [ output_image ] = imcropcenter( input_image, coordinates )
%imcropcenter uses the imcrop function to crop around center coordinate
%   coordinates is a 1x4 vector where the first two values are the center
%   x and y coordinates and the second two values are the size of the
%   cropped region in pixels for x and y axis.

x = coordinates(1);
y = coordinates(2);
xcrop = coordinates(3);
ycrop = coordinates(4);

if xcrop/2 > x
    error('Center X coordinate is too close to the edge for your cropped dimentions')
end
if ycrop/2 > y
    error('Center Y coordinate is too close to the edge for your cropped dimentions')
end

output_image = imcrop(input_image,[(x+1-xcrop/2) (y+1-ycrop/2) xcrop-1 ycrop-1]);

end

