%load('DH-0036.mat')
thlevel=0.25;
figurenum=40;
erodenum=0;
dilatenum=0;
ca = 0.028; 
separate = 0.035;
%{
E0=fp_imload('9x75_6lens2-12mmm_0500.tif','background.mat');
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
[Imin, zmap] = fp_minint(E0, 0, 7E-3, 50, 632.8e-9, eps);
figure(11);colormap(gray)
imagesc(E0)
%}

% this box is a diagnal matrix
% box = [1 1 1];
% box=convmtx(box,10)';

% this box is a verticle matrix
box=zeros(5);
box(:,3)=1;

figure(12)
hist(Imin(:),10000)

th = Imin<thlevel;
%th(700:end,1200:end)=0;
% %th = imdilate(th,ones(3));
% th = imdilate(th, box);
% th = imdilate(th, box);
% %th = imdilate(th, box);
% %th = imdilate(th,ones(4));
% th = imerode(th,box); 
% % th = imdilate(th,ones(4));
% th = imerode(th,ones(3)); 
% th = imdilate(th,ones(4));
% th = imerode(th,ones(4)); 
% th = imdilate(th,ones(5));
% th = imerode(th,ones(5)); %looks in neighborhood of ero area
% th = imdilate(th,ones(6));
% th = imerode(th,ones(6)); %looks in neighborhood of ero area
% th = imdilate(th,ones(7));
% th = imerode(th,ones(7)); %looks in neighborhood of ero area
% th = imdilate(th,ones(8));
% th = imerode(th,ones(8)); %looks in neighborhood of ero area
% th = imdilate(th,ones(9));
% th = imerode(th,ones(9)); %looks in neighborhood of ero area
% th = imdilate(th,ones(20));
% th = imerode(th,ones(20)); %looks in neighborhood of ero area
% th = imdilate(th,ones(9));

figure(13)
imagesc(th)
%th = bwmorph(th,'skel',Inf);
figure(14), imagesc(th)


figure(15)
imagesc(zmap)
figure(16)
imagesc(Imin)

figure(figurenum)
zth = zeros(size(zmap));
zth(th) = zmap(th);
cb = max(zth(:));
imagesc(zth,[ca,cb])
title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum),...
';  dilate window==',num2str(dilatenum))); colorbar;

% separate multiple depths
zth1=zth>ca&zth<separate;
zth2=zth>separate;
zmap1 = zeros(size(zmap));
zmap2 = zeros(size(zmap));
zmap1(zth1)=zmap(zth1);
zmap2(zth2)=zmap(zth2);
%
figure(figurenum+1)
imagesc(zmap1,[ca,separate])
title(strcat('Below (mm)==',num2str(separate),'threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum),...
';  dilate window==',num2str(dilatenum))); colorbar;
%
figure(figurenum+2)
imagesc(zmap2,[separate,cb])
title(strcat('Above (mm)==',num2str(separate),'threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum),...
';  dilate window==',num2str(dilatenum))); colorbar;



% 
% %2
% thlevel=thlevel-.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<(thlevel);
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %3
% thlevel=thlevel-.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% thlevel=thlevel-.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %4
% thlevel=thlevel;
% erodenum=erodenum+1;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %5
% thlevel=thlevel+0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %6
% thlevel=thlevel+0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %7
% thlevel=thlevel+0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %8
% thlevel=thlevel;
% erodenum=erodenum+1;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %9
% thlevel=thlevel-0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %10
% thlevel=thlevel-0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
% 
% %11
% thlevel=thlevel-0.025;
% erodenum=erodenum;
% figurenum=figurenum+1;
% th = Imin<thlevel;
% th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
% figure(figurenum)
% zth = zeros(size(zmap));
% zth(th) = zmap(th);
% imagesc(zth)
% title(strcat('threshold level== ',num2str(thlevel),';  erode window==',num2str(erodenum)))
