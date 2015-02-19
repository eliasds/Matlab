E0=fp_imload('40x75_6lens2-12mm_0500.tif','background.mat');
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
[Imin, zmap] = fp_minint(E0, 0, 7E-3, 50, 632.8e-9, eps);
figure(11);colormap(gray)
imagesc(E0)
figure(12)
hist(Imin(:),100)
figure(13)
th = Imin<.7;
imagesc(th)
figure(14)
zth = zeros(size(zmap));
zth(th) = zmap(th);
imagesc(zth)
figure(15)
imagesc(zmap)
figure(16)
imagesc(Imin)