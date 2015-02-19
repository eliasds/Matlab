%% Fresnel Propagation of Multiple Images Through Focus.
% Load Fresnel Propagator for several images and propagate through focus.
% Version 3.0

filename={'cuv-mag8_55EFLx75_6FL_0001','tif'};
M=8.84; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=.1e-3; % Starting z position in meters
b=4e-3; % Ending z position in meters
c=100; % number of steps


%E0=flipud(fp_imload(strcat(filename{1},'.',filename{2}))); loop=0;
%E0=fp_imload(strcat(filename{1},'.',filename{2})); loop=0;
E0=E0_div_c;
%E0=E0_1_c;

%%
%
tic
loop=0;
%screensize=get(0,'screensize');
screensize=[1,1,750,700];
fig99=figure(99);set(fig99,'colormap',gray,'Position',screensize);
for z=a:(b-a)/(c-1):b
    %loop=loop+1
    [E1,H]=fp_fresnelprop(E0,632.8e-9,z,eps);
    %imagesc(abs(E1(512:1023,1024:1535).^2),[0 255]);title(strcat('Z= +',num2str(z)),'FontSize',16);
    imagesc(abs(E1(1:end,1:end)),[(min(E0(:))-1) (1+max(E0(:)))]);title(strcat('Z= +',num2str(z)),'FontSize',16);
    drawnow
end
toc
%

