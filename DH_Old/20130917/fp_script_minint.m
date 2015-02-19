%E0=double(imread('4f at 1-32000 dilution_b.tif'));
%figure(1);colormap(gray)
%imagesc(E0)
%background=double(imread('4f at 1-32000 dilution bkg.tif'));
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
%[Imin, zmap] = fp_minint(E00c, 2E-3, 12E-3, 400, 632.8e-9, 6.5e-6);
[Imin1, zmap1] = fp_minint(E01c, 2E-3, 12E-3, 400, 632.8e-9, 6.5e-6);
%[Imin2, zmap2] = fp_minint(E02c, 2E-3, 12E-3, 400, 632.8e-9, 6.5e-6);
%figure(1);colormap(gray)
%background=background(1:1024,1700-1023:1700);
% imagesc(background)
%figure(2);colormap(gray)
%imagesc(E00c)
figure(3);colormap(gray)
imagesc(E01c)
figure(4);colormap(gray)
imagesc(E02c)
figure(5)
hist(Imin1(:),100)
th = Imin1<.7;
figure(6)
imagesc(th)
zth = zeros(size(zmap1));
zth(th) = zmap1(th);
figure(7)
imagesc(zth)
% figure(8)
% hist(Imin2(:),100)
% th = Imin2>.4;
% figure(9)
% imagesc(th)
% zth = zeros(size(zmap2));
% zth(th) = zmap2(th);
% figure(10)
% imagesc(zth)