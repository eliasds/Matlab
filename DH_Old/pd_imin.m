%% IMIN - Find the minimum intensity of all images in folder and saves them
% 
% Version 1.0
clear all
tic
%parallelproc=false;
dirname = '';
filename    = 'DH_000';
background = 'background.mat';
M=4; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=0.5E-3;
b=9E-3;
c=10;
%thlevel=0.73;
%erodenum=5;
radix2=2048;
zpad=4096;

%{
filename    = '40x75_6lens2-12mm_';
background = 'background.mat';
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=0;
b=7E-3;
c=700;
thlevel=0.75;
erodenum=5;
radix2=1024;
%}


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
background=background.(varnam{1});

%numfiles=2;
E1(numfiles).time=[];
%E1(numfiles)=struct('time',[]);
wb = waitbar(1/numfiles,['Analysing Data']);
%parfor_progress(numfiles); % Initialize 
%matlabpool open 12
%parfor i=1:numfiles % FYI: for loops always reset 'i' values.
for i=1:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    E0 = (double(imread([filesort(i).name]))./background);
    %center=round(size(E0)/2);
    %Center,Center
    %E0=E0((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));


    [Imin, zmap] = fp_minint(E0, a, b, c, 632.8e-9, eps, zpad);
    %parsave(filesort2(i).mat,Imin,zmap);
    
    parfor_progress; % Count 
    waitbar(i/numfiles,wb);
end

%matlabpool close;   
close(wb);
%parfor_progress(0); % Clean up
toc
    