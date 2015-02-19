function [th] = wd_auto(Imin, zmap, thlevel, erodenum, xcrop, ycrop);
th = Imin<thlevel;
whiskers = zeros(size(zmap));
whiskers(th) = zmap(th);
%Crop whiskers from face
th(ycrop:end,xcrop:end)=0;

%Create diagonal array for erosion
box = [1 1 1];
box=convmtx(box,10)';

%Dilate, erode and skelotonize
th = imdilate(th,ones(erodenum-1));
th = imdilate(th, box);
th = imerode(th,ones(erodenum));
th = bwmorph(th,'skel',Inf);

th = bwlabel(th);
autodetstruct = regionprops(th,zmap,'MeanIntensity','PixelIdxList');
for m = 1:numel(autodetstruct)
    idx = autodetstruct(m).PixelIdxList;
    th(idx) = autodetstruct(m).MeanIntensity;
end

%th(ycrop:end,xcrop:end) = whiskers(ycrop:end,xcrop:end);