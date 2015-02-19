% Fresnel propagation by Jingshan Zhong
%reference: NON¨CUNIFORM SAMPLING AND GAUSSIAN PROCESS REGRESSION IN TRANSPORT OF
%INTENSITY PHASE IMAGING (2014 ICASSP paper submitted)

% two measuring schemes: (1) EquallySpaced: measuring positions z are equally
% spaced; (2) NonEquallySpaced: z grows exponentially.

close all;clear all;

%%
load SMALL_HEAD; %loading true complex field

MeasuringMethod='EquallySpaced';
savefile='PurePhase_dz10umNz51Ps2um_EquallySpaced';

%MeasuringMethod='NonEquallySpaced';
%savefile='PurePhase_Nz21Ps2um_NonEquallySpaced';

TrueImg=exp(1i*(3*angle(Smallhead))); %Pure phase
[Nx,Ny]=size(TrueImg);

%parameters; unit: meter
lambda=6.328e-07; % wavelength
Amplify=1;%magnification
ps=2e-06/Amplify;%effective pixel size

%measuring positions z
Nz=51;  %  odd, number of intensity images in the simulated data
switch MeasuringMethod
    case 'EquallySpaced'
        
        dz=10e-06;%1 um step size
        nfocus=floor(Nz/2)+1;
        z=([1:1:Nz]-nfocus)*dz; 
        z=z';%store z in column vector
      
    case 'NonEquallySpaced'
        z1=10^(-6);
        alpha=0.85;% threshold
        beta=(pi-asin(alpha))/asin(alpha);% growing rate of z
        
        nfocus=floor(Nz/2)+1;
        nz=[(nfocus+1):Nz]-nfocus-1;
        
        zright=z1*beta.^nz;
        z=[-zright(length(zright):-1:1) 0 zright];
        z=z';%store z in column vector

    otherwise
        disp(['Error']);
end

avidtrue=zeros(Nx,Ny,Nz); % store complex fields
Ividmeas=zeros(Nx,Ny,Nz); % Measured intensity

%figure;
%plot(z);

%% simulating the space propagation to z

gamma=1;
NoiseLevel=0;

%nfocus=floor((Nz/2+1)); % focus is at center

N=Nx*Ny;
margin=50;%padding
nx=Nx+2*margin;
ny=Ny+2*margin;% put the image at the center with a margin; be careful about whether the border is continous

dfx = 1/nx/ps;
dfy = 1/ny/ps;
%
[Kxdown,Kydown] = ndgrid(single(-nx/2:nx/2-1),single(-ny/2:ny/2-1));
Kxdown = Kxdown*dfx;
Kydown = Kydown*dfy;

ahat0=ones(nx,ny);
ahat0(margin+1:margin+Nx,margin+1:margin+Ny)=TrueImg;
bhat0=fftshift(fft2(ahat0));

Ichunk_complex=zeros(nx, ny, Nz);

tic

for k=1:Nz
    DH=exp(-1i*lambda*pi*(abs(Kxdown.^2)+abs(Kydown.^2))*z(k));%Fresnel propagation
    bhat=DH.*bhat0;
    Ichunk_complex(:,:,k)= ifft2(ifftshift(bhat)); 
end

toc

avidtrue=Ichunk_complex(margin+1:margin+Nx,margin+1:margin+Ny,:);
Ividmeas=abs(avidtrue.^2)+randn(size(avidtrue))*NoiseLevel;%adding Gausssian noise, NoiseLevel default value is 0;

save(savefile,'Ividmeas', 'avidtrue', 'TrueImg','ps',  'lambda', 'z', 'gamma' ,'nfocus');

%% show image

figure;
subplot(1,2,1);
imagesc(abs(ahat0.^2));
%         imagesc(angle(avidtrue(1:xk,1:yk,Nz-k+1)),[minphest maxphest]);
axis image;axis off;colormap gray
title('true intensity');colorbar
subplot(1,2,2);
imagesc(angle(ahat0));
axis image;axis off;colormap gray
title('true phase');colorbar

figure;
for k=1:Nz
    
    subplot(2,2,1);
    imagesc(abs(Ichunk_complex(:,:,k).^2));
    %         imagesc(angle(avidtrue(1:xk,1:yk,Nz-k+1)),[minphest maxphest]);
    axis image;axis off;colormap gray
    title(sprintf('Intensity at z step %d',k));colorbar
   
    subplot(2,2,2);
    imagesc(angle(Ichunk_complex(:,:,k)));
    axis image;axis off;colormap gray
    title(sprintf(' Phase at z step %d',k));colorbar
    
    subplot(2,2,3);
    imagesc(Ividmeas(:,:,k));
    %         imagesc(angle(avidtrue(1:xk,1:yk,Nz-k+1)),[minphest maxphest]);
    axis image;axis off;colormap gray
    title(sprintf('Intensity without padding at z step %d',k));colorbar
   
    
    pause(0.5)
    
end



