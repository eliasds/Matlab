%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0

filename={'40x75_6lens2-12mm_0500','tif'};
background='background.mat'; %comment out if no background file
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=(0e-3); % Starting z position in meters
b=(7e-3); % Ending z position in meters
c=50; % number of steps

if exist('background','var')==1
    E0=fp_imload(strcat(filename{1},'.',filename{2}),background);
else
    %E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
     E0=fp_imload(strcat(filename{1},'.',filename{2}));
end

%%
%
tic
loop=0;
%screensize=get(0,'screensize');
screensize=[1,1,750,700];
fig99=figure(99);set(fig99,'colormap',gray,'Position',screensize);
for z=a:(b-a)/(c-1):b
    %loop=loop+1
    [E1,H]=fp_fresnelprop(E0,z,632.8e-9,eps);
    %imagesc(abs(E1(512:1023,1024:1535).^2),[0 255]);title(strcat('Z= +',num2str(z)),'FontSize',16);
    imagesc(abs(E1(1:end,1:end)),[(min(E0(:))-1) (1+max(E0(:)))]);title(strcat('Z= +',num2str(z)),'FontSize',16);
    drawnow
end
toc
%

