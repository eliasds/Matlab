%% Fresnel Propagation on CUDA/NVIDIA GPU Function.
% Version 4.0
% Describes how the image from an object gets propagated in real space.
% Digital focusing of a hologram.
% (ref pg 67,J Goodman, Introduction to Fourier Optics)
% function [E1,H] = propagate(E0,z,lambda,ps,zpad)
% inputs: E0 - complex field at input plane
%         lambda - wavelength of light [m]
%         z - propagation distance [m], (can be negative)
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:E1 - propagated complex field
%         H - propagation kernel to check for aliasing
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com

function [Imin_cpu, zmap_cpu] = fp_fresnelprop_gpu(E0,lambda,Z,ps,zpad)

% reset(gpuDevice(1));


% Set Defaults and detect initial image size
[m,n]=size(E0);
if nargin==5
    M=zpad;
    N=zpad;
elseif nargin==4
    M=m;N=n;
end


% Initialize into GPU; E1 and H
lambda = gpuArray(lambda);
Z = gpuArray(Z);
ps = gpuArray(ps);
k=(2*pi/lambda);  %wavenumber
E1_gpu = gpuArray.zeros(m,n);
Imin = gpuArray.inf(m,n)*Inf; 
zmap = gpuArray.zeros(m,n);
%H1_gpu = gpuArray.zeros(M,N,length(Z));



% Spatial Sampling
[x,y]=meshgrid(-N/2:(N/2-1), -M/2:(M/2-1));
fx=(x/(ps*M));    %width of CCD [m]
fy=(y/(ps*N));    %height of CCD [m]


% Padding value 
aveborder=gpuArray(mean(cat(2,E0(1,:),E0(m,:),E0(:,1)',E0(:,n)')));
E0_gpu=ones(M,N)*aveborder; %pad by average border value to avoid sharp jumps
E0_gpu(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)=E0;

E0fft = fftshift(fft2(E0_gpu));
fx2fy2 = fx.^2 + fy.^2;

for z = 1:length(Z)
    %h(:,:,z) = exp(1i*k*z)*exp(1i*k*(x.^2+y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
    %H1_gpu(:,:,z)  = exp(1i*k*Z(z))*exp(-1i*pi*lambda*Z(z)*(fx.^2+fy.^2)); %Transfer Function
    %E1temp=(ifft2(ifftshift(fftshift(fft2(E0_gpu)).*H1_gpu(:,:,z))));
    %H  = exp(1i*k*Z(z))*exp(-1i*pi*lambda*Z(z)*fx2fy2); %Transfer Function
    H  = exp(-1i*pi*lambda*Z(z)*fx2fy2); %Transfer Function
  %  E1temp=abs((ifft2(ifftshift(E0fft.*H)))).^2; %real, intensity
        E1temp=ifft2(ifftshift(E0fft.*H)); %real, magnitude of the field

    E1_gpu=abs(E1temp(1+(M-m)/2:(M+m)/2,1+(N-n)/2:(N+n)/2)); %real, unpadded reconstruction intensity
    
    Imin = min(Imin, E1_gpu);
    zmap(Imin==E1_gpu) = Z(z);
    
end

Imin_cpu = gather(Imin).^2;
zmap_cpu = gather(zmap);
