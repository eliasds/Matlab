filename = 'Basler_acA2040-25gm__21407047__20150810_175623686_*.tiff';

[pathstr, filename, ext] = fileparts(filename);
filename = strrep(filename, '*', '');
% filesort = dir([filename,'*',ext]);
% numfiles = numel(filesort);
figure(123);
for L = 560:9999
    figure(123);
    newfilename = [filename,num2str(L,'%0.4u'),ext];
    Holo = imread(newfilename);
    imagesc(log10(abs(fftshift(fft2(Holo)))),[4 8]);colormap gray;axis image; axis xy; title(newfilename);
    drawnow
end