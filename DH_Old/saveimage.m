%% One way to save image data
filename={'cuvette-15-30mm-50us_0001','tif'};
fig99=figure(99);
L99=double(imread(strcat(filename{1},'.',filename{2})));


imagesc(L99);axis equal;axis off;
set(fig99,'colormap',gray);
saveas(fig99,strcat('G_',filename{1}),'tif')


%% Another way to save image data
%{
filename={'cuvette-15-30mm-50us_0001','tif'};
%fig99=figure(99);
L99=double(imread(strcat(filename{1},'.',filename{2})));
screensize=get(0,'screensize');
figure('Position',screensize);
imagesc(L99);axis equal;axis off;
colormap gray;
saveas(gcf,strcat('G_',filename{1}),'eps')
%}