function [Xauto,Yauto,Zauto_centroid,Zauto_mean,Zauto_minz] = pd_auto(Imin, zmap, thlevel, erodenum);
th = Imin<thlevel;
th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
th = bwlabel(th);
autodetstruct = regionprops(th,'Centroid','PixelIdxList');
xy = [autodetstruct.Centroid];
Xauto = xy(1:2:end);
Yauto = xy(2:2:end);

%Linear Interpolation Method, using 4 pixels nearest centroid(X-Y) to
%determine z-depth. more acurate centroid method
Zauto_centroid = interp2(1:size(zmap,2),1:size(zmap,1),zmap,Xauto,Yauto);

%Determine mean Z-value from all pixels in region (biasing errors)
Zauto_mean=zeros(size(Xauto));

%Depth of Minimum intensity pixel
Zauto_minz=zeros(size(Xauto));
for i = 1:numel(autodetstruct)
    idx = autodetstruct(i).PixelIdxList;
    Zauto_mean(i) = mean(zmap(idx));
    
    particlepixels = Imin(idx);
    [~,minidx] = min(particlepixels);
    Zauto_minz(i) = zmap(idx(minidx));
end

