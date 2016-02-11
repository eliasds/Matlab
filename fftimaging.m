filename = 'Basler_acA2040-25gm.tiff';

[pathstr, filename, ext] = fileparts(filename);
filename = strrep(filename, '*', '');
filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);
filename = filesort(numfiles).name;
[pathstr, filename, ext] = fileparts(filename);
filename = filename(1:end-4);
filesort = dir([filename,'*',ext]);
numfiles = numel(filesort);

figure(123);
for L = 1:9999
    figure(123);
    filesort = dir([filename,'*',ext]);
    numfiles = numel(filesort);
    newfilename = [filename,num2str(numfiles-1,'%0.4u'),ext];
    Holo = imread(newfilename);
    imagesc(log10(abs(fftshift(fft2(Holo)))),[4 8]);colormap gray;axis image; axis xy; title(newfilename);
    drawnow
end