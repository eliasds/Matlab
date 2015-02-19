% 20um particles
%load('1E-5Dilute_0001.mat')
%E0=fp_imload('1E-5Dilute_0001.tif','background.mat');
thlevel=0.0010;
figurenum=42;
erodenum=1;

%{
% 10um particles
E0=fp_imload('DH_0001.tif','background.mat');
load('DH_0001.mat')
thlevel=0.7;
figurenum=40;
erodenum=4;
%}

%E0=fp_imload('DH_0001.tif','background.mat');
% M=4; %Magnification
% eps=6.5E-6 / M; %Effective Pixel Size in meters
% [Imin, zmap] = fp_minint(E0, 0.5, 9E-3, 4, 632.8e-9, eps);
figure(11);colormap(gray)
imagesc(E0)

figure(12)
hist(Imin(:),200)
figure(13)
th = Imin<thlevel;
th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
imagesc(th)
figure(figurenum);%colormap gray;
zth = zeros(size(zmap));
zth(th) = zmap(th);
imagesc(zth)
title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
figure(15)
imagesc(zmap)
figure(16)
imagesc(Imin)