%% Version for sample 0140210-Whiskers\340hz 2000x1088\12-55-59.959

function [th] = wd_auto(Imin, zmap, thlevel, erodenum, xcrop, ycrop);

th = Imin<thlevel;
whiskers = zeros(size(zmap));
whiskers(th) = zmap(th);

%Crop whiskers from face
if nargin>4
    th(ycrop:end,xcrop:end)=0;
end


%Create diagonal array for erosion
% box = [1 1 1];
% box=convmtx(box,10)';

%Create verticle array for erosion
box=zeros(5);
box(:,3)=1;

%Dilate, erode and skelotonize
th = imdilate(th,box);
th = imdilate(th, box);
th = imerode(th,box);
th = bwmorph(th,'skel',Inf);

th = bwlabel(th);
autodetstruct = regionprops(th,zmap,'MeanIntensity','PixelIdxList');
for m = 1:numel(autodetstruct)
    idx = autodetstruct(m).PixelIdxList;
    th(idx) = autodetstruct(m).MeanIntensity;
end

%th(ycrop:end,xcrop:end) = whiskers(ycrop:end,xcrop:end);