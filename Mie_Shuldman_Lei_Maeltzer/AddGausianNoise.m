Holo2noise=Holo;
%Holo2noise=abs(Eout).^2;
%onesarray=ones(size(Intensity1,1),size(Intensity1,2));
minI=min(Holo2noise(:));
Holo2noise=Holo2noise-minI;
maxI=max(Holo2noise(:));
scale1=1./maxI;
Holo2noise=Holo2noise.*scale1;
Holo2 = imnoise(Holo2noise,'gaussian',0,0.01);