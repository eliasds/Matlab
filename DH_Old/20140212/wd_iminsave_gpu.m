%% IMIN - Find the minimum intensity of all whiskers
%         in images in folder and saves them
% 
% Version 1.0
clear all
tic
dirname = '';
filename    = 'DH-';
background = 'background.mat';
M=0.5; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in meters
lambda=785E-9; %laser wavelength in meters
a=25E-3;
b=45E-3;
c=201;
Zin=linspace(a,b,c);
Zout=Zin;
radix2=2048;
zpad=2048;
maxint=6; %overide default max intensity: 3*mean(Imin(:))


filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
filesort2(numfiles)=struct('path',[],'name',[],'ext',[],'mat',[]);
for i = 1:numfiles
    [filesort2(i).path, filesort2(i).name, filesort2(i).ext] =fileparts([filesort(i).name]);
    filesort2(i).mat=strcat(filesort2(i).name,'.mat');
end
varnam=who('-file',background);
background=load(background,varnam{1});
background=gpuArray(background.(varnam{1}));

temp = (double(imread([filesort(1).name]))./background);
maxint=2*mean(temp(:));

%numfiles=2;
E1(numfiles).time=[];
%E1(numfiles)=struct('time',[]);
wb = waitbar(1/numfiles,['Analysing Data']);
for i=1:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    E0 = (double(imread([filesort(i).name]))./background);
    E0(isnan(E0)) = mean(background(:));
    E0(E0>maxint)=maxint;
    
    [Imin, zmap] = fp_imin_gpu(E0,lambda,Zout,eps,zpad);
    save(filesort2(i).mat,'Imin','zmap');
    
    waitbar(i/numfiles,wb);
end

close(wb);
toc
    