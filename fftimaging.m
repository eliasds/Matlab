filenameinit = 'Basler_.tiff';
filenameinit = '*.tiff';

[pathstr, filenameinit, ext] = fileparts(filenameinit);
filenameinit = strrep(filenameinit, '*', '');
filesort = dir([filenameinit,'*',ext]);
filename = filesort(1).name;
Holo = imread(filename);
[~, filename, ~] = fileparts(filename);
filename = filename(1:end-4);

fignum = 124;
figure1 = figure(fignum);
subplot(3,5,[1:3 6:8 11:13]);
handle1 = imagesc(Holo,[.0 1]);
colormap gray;axis image; axis ij;colorbar;
title1 = title([filenameinit,num2str(1,'%0.4u')]);
subplot(3,5,4:5);
handle2 = histogram(Holo(:));
title('Histogram');
subplot(3,5,[9:10 14:15]);
handle3 = imagesc(Holo);
colormap gray;axis image;axis ij;axis off;title('Raw');
numfileslast = 0;
numfiles = inf;
while numfileslast ~= numfiles
    filesort = dir([filename,'*',ext]);
    numfileslast = numfiles;
    numfiles = numel(filesort);
    newfilename = [filename,num2str(numfiles,'%0.4u'),ext];
    pause(.5)
    Holo = imread(newfilename);
    dynrange0 = min(Holo(:));
    dynrange1 = max(Holo(:)); %max value just over 255 optimizes dynamic range
    HoloFFT = log10(abs(fftshift(fft2(Holo))));
    HoloFFT = (HoloFFT - min(HoloFFT(:)))/(max(HoloFFT(:))-min(HoloFFT(:)));
    HoloFFT_adapthisteq = adapthisteq(HoloFFT);
%     figure(fignum);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)]);drawnow
%     figure(fignum);subplot(3,5,[1:3 6:8 11:13]);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)]);subplot(3,5,4:5);histogram(Holo(:));axis off;title('Histogram');drawnow
%     figure(fignum);subplot(3,5,[1:3 6:8 11:13]);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; 
    set(handle1,'CData',HoloFFT_adapthisteq);set(title1,'String',[filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)]);
    subplot(3,5,4:5);histogram(Holo(:));title('Histogram');
    set(handle3,'CData',Holo)
    drawnow

end
