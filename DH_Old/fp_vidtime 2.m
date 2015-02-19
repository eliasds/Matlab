%% Fresnel Propagation of Multiple Images Through Time.
% Load Fresnel Propagator for several images and create time lapse.
% Version 1.0


%%
%
filename={'DH-','tif'};
framerate=20;
%common image scaling; 1 (for raw data), 128 (for background divided
%images), 1/256 for 16 bit images, 1/16 for 12 bit images.
imsc=128; %common image scaling; 1, 128, 1/256,
M=1; %M=0.36; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in microns
lambda=635e-9;
zpad=2048;
a=1; % Starting file/frame
b=200; % Ending file/frame
numsteps=1+b-a; %Number of frames
z=0e-3; %propagation z distance
%
eval(['filenames = dir(''' filename{1} '*.' filename{2} ''');']);
numfiles = length(filenames);
E0=fp_imload(filenames(1, 1).name); loop=0;

%%
tic
[m,n]=size(E0);
clear F; F(numsteps) = struct('cdata',[],'colormap',[]);%Preallocate video array
writerObj = VideoWriter(strcat(filename{1},'_',num2str(uint8(rand*100))),'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
wb = waitbar(1/(1.1*numsteps),['Analysing Data']);
for L=a:b
    loop=loop+1;
    E0=fp_imload(filenames(L, 1).name,'background.mat');
    %E0=flipud(fp_imload(filenames(L, 1).name));
    %E0=rot90(fp_imload(filenames(L, 1).name)); %also switch (m,n) in F
    E0(isnan(E0)) = 0;
    if z==0
        E1=E0;
    else
        E1=fp_fresnelprop(E0,lambda,z,eps,zpad);
    end
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1).*imsc);
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
    waitbar(loop/(numsteps),wb);
end
close(writerObj);
close(wb);
toc
