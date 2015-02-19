%% List of constants and scripts to run whisker detection
%
clear all

frame_num1 = 1; %1st frame to analyze
frame_num2 = 1; %last frame to analyze
numframes=1+frame_num2-frame_num1;

thlevel=0.05;
erodenum=8; % 3 imerode window, erodes with an nxn matrix

dirname = '';
filename    = 'DH-';
background = 'background.mat';
M=0.5; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in meters
lambda=787E-9; %laser wavelength in meters
a = 70E-03;
b = 90E-03;
c = 1+(b-a)/10E-06;
Zin=linspace(a,b,c);
Zout=Zin;
radix2=2048;
zpad=2048;
%maxint=6; %overide default max intensity: 2*mean(Imin(:))
xcrop1=1;
xcrop2=1968;
ycrop1=1;
ycrop2=1088;
zmin=70E-3; %don't plot below this z depth for better colormap and video
zmax=90E-3;
fignum=20;
tic

%%
%Filename Sorting
filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
for L = 1:numfiles
    [filesort(L).path, filesort(L).matname, filesort(L).ext] =fileparts([filesort(L).name]);
    filesort(L).mat=strcat(filesort(L).matname,'.mat');
end

%%
%Background Averaging
%fp_avg_bgfiles %~1 min for 1000frames

%%
%Calculate Minimum intensity
%calls function(s): fp_imin_gpu.m
%~2 hours for 1000frames
varnam=who('-file',background);
background=load(background,varnam{1});
background=gpuArray(background.(varnam{1}));

E0 = gather((double(imread([filesort(1).name]))./background));
if exist('maxint')<1
    maxint=2*mean(E0(:));
end

E1(numfiles).time=[];
wb = waitbar(1/numframes,['Analysing Minimum Intensity']);
for L=frame_num1:frame_num2 % FYI: for loops always reset 'i' values.
    % import data from tif files.
    E0 = (double(imread([filesort(L).name]))./background);
    E0(isnan(E0)) = mean(background(:));
    E0(E0>maxint)=maxint;

    
    [Imin, zmap] = fp_imin_gpu(E0,lambda,Zout,eps,zpad);
    save(filesort(L).mat,'Imin','zmap','-v7.3');
    
    waitbar(L/numframes,wb);
end

E0=gather(E0);
background=gather(background);
maxint=gather(maxint);
close(wb);



%%
%Detect Whiskers
%calls function(s): %wd_auto.m
%~20 min for 1000frames
[m,n]=size(Imin);
beadxyz(numfiles).time=[];
wb = waitbar(1/numframes,['Detecting Whiskers']);
for L=frame_num1:frame_num2 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(L).mat]);

    th = wd_auto(Imin, zmap, thlevel, erodenum, xcrop1, ycrop1);
%    th = wd_auto(Imin, zmap, thlevel, erodenum);
    whiskers(L).time=[th];
    %
    %
    waitbar(L/numframes,wb);
end

close(wb);


save(strcat(filename,'0_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er.mat'), 'whiskers','-v7.3')
figure
hist(Imin(:),10000)

%%
for L=frame_num1:frame_num2
    figure(fignum)
    %set(fignum,'Position',[10,150,1010,550],'color','w');
    wd_3dplot(whiskers(L).time,zmin,zmax,xcrop1,xcrop2,ycrop1,ycrop2)
    %wd_3dplot(whiskers(L).time,zmin) 
    title(['Time:',num2str(L)]);
    grid on
    box on
    drawnow
    %hold on
    %pause(0.1)
    %hold off
    mov(:,L) = getframe(fignum) ;
    %clf
end

toc
