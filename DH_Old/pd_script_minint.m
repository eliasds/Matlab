clear all;load('DH_0500.mat');
thlevel=0.55;
figurenum=40;
erodenum=0;
mindil=12;
dilatenum=mindil;
ca = 0.00; 
cb = 0.01;
separate = 0.0035;
n=4;
%{
E0=fp_imload('9x75_6lens2-12mmm_0500.tif','background.mat');
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
[Imin, zmap] = fp_minint(E0, 0, 7E-3, 50, 632.8e-9, eps);
figure(11);colormap(gray)
imagesc(E0)
%}

disk1 = strel('disk', dilatenum, 0);
disk2 = strel('disk', erodenum, 0);

%box=convmtx(box,10)';
%box=[ 1 1 1 0 0 0 0; 1 1 1 0 0 0 0; 0 1 1 1 0 0 0; 0 1 1 1 0 0 0; 0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 0 0 1 1 1 0; 0 0 0 1 1 1 0; 0 0 0 0 1 1 1;  0 0 0 0 1 1 1];

figure(10)
hist(Imin(:),10000)

th = Imin<thlevel;
figure(11);imagesc(th)
%th(700:end,1200:end)=0;
th = imdilate(th, disk1);
figure(12);imagesc(th);
% th = imdilate(th, disk1);
% figure(13);imagesc(th);
%th = imerode(th,disk2); %looks in neighborhood of ero area
figure(14);imagesc(th)

figure(15);imagesc(zmap)
figure(16);imagesc(Imin)

figure(figurenum)
zth = zeros(size(zmap));
zth(th) = zmap(th);
%cb = max(zth(:));
imagesc(zth,[ca,cb])
[L, num] = bwlabel(th, n);
title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
figure(n/2);imagesc(L);colorbar
% 
% %2
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<(thlevel);
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% figure(n/2+1);imagesc(L);colorbar
% 
% %3
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% figure(n/2+2);imagesc(L);colorbar
% 
% %4
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% figure(n/2+3);imagesc(L);colorbar
% 

% 
% %5
% thlevel=thlevel+0.025;
% erodenum=erodenum;
% dilatenum=mindil;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% %6
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% 
% %7
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% %8
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% 
% %9
% thlevel=thlevel+0.025;
% erodenum=erodenum;
% dilatenum=mindil;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% %10
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% %11
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
% 
% %12
% thlevel=thlevel;
% erodenum=erodenum;
% dilatenum=dilatenum+2;
% disk1 = strel('disk', dilatenum, 0);
% disk2 = strel('disk', erodenum, 0);
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imdilate(th, disk1);
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth,[ca,cb])
% [L, num] = bwlabel(th, n);
% title(strcat('threshold level== ',num2str(thlevel),';  erode==',num2str(erodenum),...
% ';  dilate==',num2str(dilatenum),';  #Part==',num2str(num))); colorbar;
% 
