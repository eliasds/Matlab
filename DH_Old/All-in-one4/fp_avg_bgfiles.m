%% Fresnel Propagation Background Averager.
% 
% Version 2.0

dirname = '';
filename    = 'DH-';
filext = 'tif';
tic
filename = strcat(dirname,filename);
filesort = dir([filename,'*.',filext]);
numfiles = length(filesort);

bg=double(imread([filesort(1).name]));

wb = waitbar(1/numfiles,['importing']);
for m=1:numfiles 
    
    % import data from ASCII files.
    bg=bg+double(imread([filesort(m).name]));
    waitbar(m/numfiles,wb);
end

close(wb);

bg=bg/numfiles;

save('background.mat','bg');
toc