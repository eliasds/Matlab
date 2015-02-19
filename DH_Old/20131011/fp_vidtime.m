%% Fresnel Propagation of Multiple Images Through Time.
% Load Fresnel Propagator for several images and create time lapse.
% Version 1.0


%%
%
filename={'cuvette-15-30mm-50us_','tif'};
framerate=20;
z=0.4e-3; %propagation z distance
M=1; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in microns
a=1; % Starting file/frame
b=9; % Ending file/frame
c=1+b-a; %Number of frames
%


%%
tic
eval(['filenames = dir(''' filename{1} '*.' filename{2} ''');']);
numfiles = length(filenames);
E0=fp_imload(filenames(1, 1).name); loop=0;
[m,n]=size(E0);
clear F; F(c) = struct('cdata',[],'colormap',[]);%Preallocate video array
writerObj = VideoWriter(strcat(filename{1},'_',num2str(uint8(rand*100))),'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
for L=a:b
    E0=fp_imload(filenames(L, 1).name);
    %E0=flipud(fp_imload(filenames(L, 1).name));
    %E0=rot90(fp_imload(filenames(L, 1).name)); %also switch (m,n) in F
    %[E1,H]=fp_fresnelprop(E0,632.8e-9,z,eps);
    E1=E0;
    loop=loop+1; if rem(10*loop,c)==0 || rem(c,loop)==0; fprintf('Percentage complete:');disp(100*loop/c); end
    F(loop).cdata=uint8(zeros(m,n,3));
    F(loop).cdata(:,:,1)=uint8(abs(E1));
    F(loop).cdata(:,:,2)=F(loop).cdata(:,:,1);
    F(loop).cdata(:,:,3)=F(loop).cdata(:,:,1);
    writeVideo(writerObj,F(loop));
end
close(writerObj);
toc
