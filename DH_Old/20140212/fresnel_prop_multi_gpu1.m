function [Ef] = fresnel_prop_multi_gpu(E0,N,ps,lam,zall)
%function Ef = fresnel_prop(E0,N,ps,lam,z)
%Function Input: Initial field in x-y, wavelength lam, no of sample points N, pixel size in um say,z value
%Function output: Final field in x-y after Fresnel Propagation    
%(ref pg 67,J Goodman, Introduction to Fourier Optics)

%%
%Spatial Sampling
xsize =  ps*N; ysize = ps*N;
fprintf('\nIn um\n');
Pixel_Size = xsize/N                 %Print pixel size

%Send to GPU
E0_gpu = gpuArray(E0);

%The real proper way
wx = 2*pi*(0:(N-1))/N; %Create unshifted default omega axis
wx = gpuArray(wx);
%fx =1/ps*unwrap(fftshift(wx)-2*pi)/2/pi; 
fx = 1/ps*(wx-pi*(1-mod(N,2)/N))/2/pi; %Shift zero to centre - for even case, pull back by pi, for odd case by pi(1-1/N)
[Fx,Fy] = meshgrid(fx,fx);

H = gpuArray.zeros(N,N,length(zall));
parfor z = 1:length(zall)
    H(:,:,z) = exp(1i*pi*lam*zall(z)*(Fx.^2+Fy.^2));
end

E0fft = fftshift(fft2(E0_gpu));                 %Centred about zero (as fx and fy defined to be centred around zero)

g = gpuArray.zeros(N,N,length(zall));
parfor z = 1:length(zall)
    g(:,:,z) = ifft2(ifftshift(H(:,:,z) .* E0fft)); 
end

%Outputs after deshifting the fourier transform
Ef=gather(g);