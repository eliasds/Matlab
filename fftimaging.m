filenameinit = 'Basler_.tiff';

[pathstr, filenameinit, ext] = fileparts(filenameinit);
filenameinit = strrep(filenameinit, '*', '');
filesort = dir([filenameinit,'*',ext]);
filename = filesort(1).name;
[~, filename, ~] = fileparts(filename);
filename = filename(1:end-4);

fignum = 124;
figure(fignum);
while 1
    filesort = dir([filename,'*',ext]);
    numfiles = numel(filesort);
    newfilename = [filename,num2str(numfiles,'%0.4u'),ext];
    Holo = imread(newfilename);
    dynrange0 = min(Holo(:));
    dynrange1 = max(Holo(:)); %max value just over 255 optimizes dynamic range
    HoloFFT = log10(abs(fftshift(fft2(Holo))));
    HoloFFT = (HoloFFT - min(HoloFFT(:)))/(max(HoloFFT(:))-min(HoloFFT(:)));
    HoloFFT_adapthisteq = adapthisteq(HoloFFT);
%     figure(fignum);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)]);drawnow
    figure(fignum);subplot(3,4,[1:3 5:7 9:11]);imagesc(HoloFFT_adapthisteq,[0.35 1]);colormap gray;axis image; axis xy; title([filenameinit,num2str(numfiles,'%0.4u'),'  Dyn Range: ',num2str(dynrange0),'-',num2str(dynrange1)]);subplot(3,4,4);histogram(Holo(:));axis off;title('Histogram');drawnow
end
