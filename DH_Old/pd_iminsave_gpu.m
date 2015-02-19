%% IMIN - Find the minimum intensity of all images in folder and saves them
% 
% Version 1.0
clear all
tic
dirname = '';
filename    = 'DH_';
background = 'background.mat';
M=5; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
lambda=632.8E-9/1.33; %laser wavelength in meters
a=0E-3;
b=10E-3;
c=201;
Zin=linspace(a,b,c);
Zout=Zin;
zpad=2048;
%maxint=6; %overide default max intensity: 2*mean(Imin(:))
%test=40;
radix2=1024;
vortloc=[1200,2160]; %location of vorticella in "cuvette in focus"
%vortloc=[1550,2160]; %location of vorticella in "vort in focus"



filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
for i = 1:numfiles
    [filesort(i).path, filesort(i).matname, filesort(i).ext] =fileparts([filesort(i).name]);
    filesort(i).mat=strcat(filesort(i).matname,'.mat');
end
varnam=who('-file',background);
background=load(background,varnam{1});
background=gpuArray(background.(varnam{1}));

%E0 = gather((double(imread([filesort(1).name]))./background));
E0 = gather((double(imread([filesort(1).name]))));
%E0 = gather(double(background));
if exist('maxint')<1
    maxint=2*mean(E0(:));
end

if exist('test')
    numfiles=test;
end

E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for i=1:100:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    E0 = (double(imread([filesort(i).name])));
    %E0 = (double(imread([filesort(i).name]))./background);
    E0=E0(vortloc(2)-radix2+1:vortloc(2),vortloc(1)-radix2/2:vortloc(1)-1+radix2/2);
    %E0=E0(1882-768:1882+255,1353-511:1353+512);
    %E0 = (double(background));
    %E0(isnan(E0)) = mean(background(:));
    E0(E0>maxint)=maxint;
    
    [Imin, zmap] = fp_imin_gpu(E0,lambda,Zout,eps,zpad);
    save(filesort(i).mat,'Imin','zmap','-v7.3');
    
    waitbar(i/numfiles,wb);
end

E0=gather(E0);
background=gather(background);
maxint=gather(maxint);
close(wb);
toc
