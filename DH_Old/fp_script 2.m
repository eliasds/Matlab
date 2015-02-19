%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0

%
filename={'DH-001','tif'};
background='background.mat'; %comment out if no background file
%
M=.36; %Magnification
M=1;
eps=5.5E-6 / M; %Effective Pixel Size in meters
zpad=2048;
lambda=635e-9;
a=(20e-3); % Starting z position in meters
b=(40e-3); % Ending z position in meters
c=21; % number of steps
%
if exist('background','var')==1
    E0=fp_imload(strcat(filename{1},'.',filename{2}),background);
else
    %E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
     E0=fp_imload(strcat(filename{1},'.',filename{2}));
end
%E0(isnan(E0)) = mean2(bg);
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
    E1=fp_fresnelprop(E0,lambda,z,eps,zpad);
    loop=loop+1;
    %
    imagesc(abs(E1(1:end,1:end)),[(min(E0(:))-1) (1+max(E0(:)))]);title(strcat('Z= +',num2str(z)),'FontSize',16);
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