%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0

%
% clear all
% filename={'DH-001','tif'};
% background='background.mat'; %comment out if no background file
%
%M=0.36; %Magnification
M=4; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
zpad=1024;
refractindex = 1.33;
lambda=632.8e-9 /refractindex;
% lambda=785e-9; %in nanometers
a=(-3.75e-3); % Starting z position in meters
b=(-8.25e-3); % Ending z position in meters
c=201; % number of steps
%
% if exist('background','var')==1
%     E0=fp_imload(strcat(filename{1},'.',filename{2}),background);
% else
%     %E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
%      E0=fp_imload(strcat(filename{1},'.',filename{2}));
% end
% E0(isnan(E0)) = 0;
%
%%
%
tic
loop=0;
%intensity=zeros(c,size(E2(1,1).time,1)+1);
%screensize=get(0,'screensize');
%screensize=[1,1,750,700];
%fig99=figure(99);set(fig99,'colormap',gray,'Position',screensize);
figure(99);colormap gray;
%wb = waitbar(1/c,'Analysing Data');
for z=a:(b-a)/(c-1):b
    Eout = propagate(Ein,lambda,z,eps,zpad);
    loop=loop+1;
    %
    figure(99);
    imagesc(abs(Eout).^2);
    title(strcat('Z= +',num2str(z)),'FontSize',16);
    colormap gray; colorbar; axis image;
    drawnow
    %
    %{
    intensity(loop,1)=z;
    for L=1:size(E2(1,1).time,1)
        intensity(loop,L+1)=abs(E1(round(E2(1,1).time(L,2)),round(E2(1,1).time(L,1))));
    end
    %}
    %waitbar(loop/c,wb);
end
%close(wb);
toc
%