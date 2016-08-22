%% Acknowledgements:
% This file was inspired by Cropping an Image with draggable rectangle
% by Shripad Kondra, 08 Nov 2007
% Crops the Image from a draggable rectangle
% & returns the Cropped Image and its co-ordinates
%
% I is the Image to be cropped assumed to be in the
% matlab workspace
%
% w : width (default value : cols/2)
% h : height (default value : rows/2)
%
% EXAMPLES
%
% I = imread('circuit.tif');
% [O] = Crop_it(I);
%
% [O I_crop]=Crop_it(I,0);
%
% [O I_crop]=Crop_it(I,1,100,100);
 
% $date 08-Nov-2007

function [O I_crop] = imload(I,w,h,varargin)

Rect_cords = round([1 1 h w]);

%% Plot the Image
figure, imshow(I); 

%%
while ~isempty(varargin)
    switch upper(varargin{1})
            
        case 'RESIZE'
            varargin(1) = [];
            k = waitforbuttonpress;
            point1 = get(gca,'CurrentPoint');    % button down detected
            finalRect = rbbox;                   % return figure units
            point2 = get(gca,'CurrentPoint');    % button up detected
            point1 = point1(1,1:2);              % extract x and y
            point2 = point2(1,1:2);
            p1 = min(point1,point2);             % calculate locations
            offset = abs(point1-point2);
            Rect_cords = round([p1 offset]);
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

if(resize)
    k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    finalRect = rbbox;                   % return figure units
    point2 = get(gca,'CurrentPoint');    % button up detected
    point1 = point1(1,1:2);              % extract x and y
    point2 = point2(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);
    Rect_cords = round([p1 offset]);
end

%% Make the rectangle
h1 = imrect(gca, Rect_cords);
%% Drag and close the figure
api = iptgetapi(h1);
waitfor(h1);
%% Crop
I_crop = imcrop(I,floor(api.getPosition())-1);
O = round(api.getPosition());
 
return;


