%E0=double(imread('40x75_6lens2-12mm_0001.tif'));
%figure(1);colormap(gray)
%imagesc(E0)
%background=double(imread('4f at 1-32000 dilution bkg.tif'));
background=bgc;
%figure(1);colormap(gray); imagesc(background)
% E1=(E0./background);
% figure(3);colormap(gray)
% imagesc(E1)
% E2=(E0-background);
% figure(4);colormap(gray)
% imagesc(E2)
% E0=E0(1:1024,1700-1023:1700);
% E1=E1(1:1024,1700-1023:1700);
% E2=E2(1:1024,1700-1023:1700);
%[Imax, zmap] = fp_maxint(E00c, 2E-3, 12E-3, 100, 632.8e-9, 6.5e-6);
%[Imax1, zmap1] = fp_maxint(E01c, 2E-3, 12E-3, 100, 632.8e-9, 6.5e-6);
[Imax2, zmap2] = fp_maxint(E02c, 2E-3, 12E-3, 100, 632.8e-9, 6.5e-6);
%figure(1);colormap(gray)
%background=background(1:1024,1700-1023:1700);
% imagesc(background)
%figure(2);colormap(gray)
%imagesc(E00c)
figure(3);colormap(gray)
imagesc(E01c)
figure(4);colormap(gray)
imagesc(E02c)
% figure(5)
% hist(Imax1(:),100)
% th = Imax1>1.2;
% figure(6)
% imagesc(th)
% zth = zeros(size(zmap1));
% zth(th) = zmap1(th);
% figure(7)
% imagesc(zth)
figure(8)
hist(Imax2(:),100)
th = Imax2>25;
figure(9)
imagesc(th)
zth = zeros(size(zmap2));
zth(th) = zmap2(th);
figure(10)
imagesc(zth)