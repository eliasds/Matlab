%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0


%%
%
filename={'DH-001','tif'};
framerate=15;
%common image scaling; 1 (for raw data), 128 (for background divided
%images), 1/256 for 16 bit images, 1/16 for 12 bit images.
imsc=1; %common image scaling; 1, 128, 1/256,
M=1; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in microns
lambda=635E-9;
zpad=2048;
a=0e-3; % Starting z position in meters
b=30e-3; % middle z position in meters
c=40e-3; % Ending z position in meters
numsteps=50; % number of steps
%E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
E0=fp_imload(strcat(filename{1},'.',filename{2}));
loop=0;
%

%%
%{
filename={'vort01_0001','tif'}; %vort01 &vort02 &vort04 &vort05 &vort06
framerate=8;
M=1; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=22e-3; % Starting z position in meters
b=32e-3; % Ending z position in meters
numsteps=100; % number of steps
E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
%E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
%}

%%
%{
filename={'vort13_0001','tif'}; %vort07
framerate=5;
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=40e-3; % Starting z position in meters
b=60e-3; % Ending z position in meters
numsteps=50; % number of steps
%E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
%}

%%
%{
filename={'vort01_0001','tif'};
framerate=5;
M=1; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=22e-3; % Starting z position in meters
b=32e-3; % Ending z position in meters
numsteps=100; % number of steps
E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
%E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
%}

%%
tic
[m,n]=size(E0);
clear F; F(numsteps) = struct('cdata',[],'colormap',[]);%Preallocate video array
writerObj = VideoWriter(filename{1},'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
wb = waitbar(1/(1.1*numsteps),['Analysing Data']);
for z=a:(b-a)/round(numsteps/10):b
    loop=loop+1;
    E1=fp_fresnelprop(E0,lambda,z,eps,zpad);
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1).*imsc);
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
    waitbar(loop/(1.1*numsteps),wb);
end
for z=b:(c-b)/(numsteps-1):c
    loop=loop+1;
    E1=fp_fresnelprop(E0,lambda,z,eps,zpad);
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1).*imsc);
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
    waitbar(loop/(1.1*numsteps),wb);
end
close(writerObj);
close(wb);
toc
