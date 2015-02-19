%% Fresnel Propagation of Multiple Images Through Time.
% Load Fresnel Propagator for several images and create time lapse.
% Version 1.0


%%
%
clear all
%filename={'DH_','tif'};
filename='DH_';
ext='tif';
dirname='';
framerate=20;
vortloc=[1200,2160]; %location of vorticella in "cuvette in focus"
%vortloc=[1550,2160]; %location of vorticella in "vort in focus"
z=4.75E-3; %propagation z distance
M=4; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
lambda=632.8E-9;
zpad=2048;
a=1; % Starting file/frame
%b=2140; % Ending file/frame
d=10; % #frames to skip
%


%%
tic
% eval(['filesort = dir(''' filename{1} '*.' filename{2} ''');']);
% numfiles = length(filesort);
filename = strcat(dirname,filename);
filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);
c=1+numfiles-a; %Number of frames
E0=fp_imload(filesort(1, 1).name);
E0=E0(vortloc(2)-1087:vortloc(2),vortloc(1)-960:vortloc(1)+959);
%load(filesort(1, 1).name,'Imin'); E0=Imin;
loop=0;
[m,n]=size(E0);
clear F; F(c) = struct('cdata',[],'colormap',[]);%Preallocate video array
if ~exist('analysis', 'dir')
  mkdir('analysis');
end
writerObj = VideoWriter(strcat('analysis\',filename,'_',num2str(uint8(rand*100))),'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
wb = waitbar(1/c,['Creating Video']);
for L=a:d:numfiles
    loop=loop+1; %if rem(10*loop,c)==0 || rem(c,loop)==0; fprintf('Percentage complete:');disp(100*loop/c); end
    %load(filesort(L, 1).name,'Imin'); E0=Imin;
    E0=fp_imload(filesort(L, 1).name);
    E0=E0(vortloc(2)-1087:vortloc(2),vortloc(1)-960:vortloc(1)+959);
    %E0=fp_imload(filesort(L, 1).name,'background.mat');
    %E0=flipud(fp_imload(filesort(L, 1).name));
    %E0=rot90(fp_imload(filesort(L, 1).name)); %also switch (m,n) in F
    %E1=fp_fresnelprop_gpu(E0,lambda,z,eps,zpad);
    E1=E0;
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1));
    %F(loop).cdata(:,:,1)=uint8(abs(E1).*128);
    %F(loop).cdata(:,:,1)=uint8(abs(E1)./256);
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
    waitbar(L/c,wb);
end
close(writerObj);
close(wb);
toc
