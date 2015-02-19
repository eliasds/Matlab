%% Fresnel Propagation Background Averager.
% 
% Version 1.0

dirname = '';
filename    = 'DH_';
filename = strcat(dirname,filename);
eval(['numfiles = dir(''' filename '*.tif'');']);
numfiles = length(numfiles);

eval(['bg=double(imread(''' filename sprintf('%04d',50) '.tif''));'])

wb = waitbar(1/numfiles,['importing']);
for i=51:numfiles % FYI: for loops always reset 'i' values.

    % import data from ASCII files.
    eval(['bg=bg+double(imread(''' filename sprintf('%04d',i) '.tif''));'])
    waitbar(i/numfiles,wb);
end

close(wb);

bg=bg/numfiles;

save('background.mat','bg');