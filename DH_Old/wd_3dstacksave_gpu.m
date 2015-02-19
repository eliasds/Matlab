%% 3D Srack - Uses fp_3dstack_gpu to create a 3D stack of
%         images in folder and saves them
% 
% Version 1.0
clear all
tic
dirname = '';
filename    = 'DH_0010';
background = 'background.mat';
M=0.5; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in meters
lambda=787E-9; %laser wavelength in meters
a=0E-3;
b=50E-3;
c=51;
d=50;
Zin=linspace(a,b,c);
Zout=Zin;
radix2=2048;
zpad=2048;
%maxint=6; %overide default max intensity: 2*mean(Imin(:))
test=1;


filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
%filesort2(numfiles)=struct('path',[],'name',[],'ext',[],'mat',[]);
for L = 1:numfiles
    [filesort(L).path, filesort(L).matname, filesort(L).ext] =fileparts([filesort(L).name]);
    filesort(L).mat=strcat(filesort(L).matname,'.mat');
end
varnam=who('-file',background);
background=load(background,varnam{1});
background=gpuArray(background.(varnam{1}));

E0 = gather((double(imread([filesort(1).name]))./background));
E0 = E0(3:end,:);
if exist('maxint')<1
    maxint=2*mean(E0(:));
end

if exist('test')
    numfiles=test;
end

E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for L=1:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    E0 = (double(imread([filesort(L).name]))./background);
    E0 = E0(3:end,:);
    E0(isnan(E0)) = mean(background(:));
    E0(E0>maxint)=maxint;
    
    [fp3d] = fp_3dstack_gpu(E0,lambda,Zout,eps,zpad);
%    save(strcat('3D',filesort(L).mat),'fp3d','Zout','-v7.3');
    
    waitbar(L/numfiles,wb);
end

E0=gather(E0);
background=gather(background);
maxint=gather(maxint);
close(wb);
toc
