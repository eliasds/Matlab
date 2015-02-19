%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0

%%
%
filename={'4f at 1-32000 dilution_a','tif'};
framerate=5;
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=.001e-3; % Starting z position in meters
b=2e-3; % Ending z position in meters
c=150; % number of steps
%E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
%

%%
%{
filename={'vort01_0001','tif'}; %vort01 &vort02 &vort04 &vort05 &vort06
framerate=8;
M=1; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=22e-3; % Starting z position in meters
b=32e-3; % Ending z position in meters
c=100; % number of steps
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
c=50; % number of steps
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
c=100; % number of steps
E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
%E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
%}

%%
tic
[m,n]=size(E0);
clear F; F(c) = struct('cdata',[],'colormap',[]);%Preallocate video array
writerObj = VideoWriter(filename{1},'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
for z=a:(b-a)/(c-1):b
    loop=loop+1; if rem(10*loop,c)==0 | rem(c,loop)==0; fprintf('Percentage complete:');disp(100*loop/c); end
    [E1,H]=fp_fresnelprop(E0,632.8e-9,z,eps,2048);
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1));
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
end
close(writerObj);
toc
