function [ phi, psi ] = Fwd_Prop_MultiSlice_v2( i0, o_slice, k2, dz, ...
    lambda, Prop_mode)
%FWD_PROP_MULTISLICE computes the field using multislice approach, with
%propagator H
% Inputs:
%   H: fwd propagator between slices
%   H0: fwd propagator from Nth slice to focal plane of objective
%   o_slice0: current estimate of multi-slice object
%   i0: KNOWN illumination

% by Lei Tian (lei_tian@alum.mit.edu)
% last modified on 5/28/2014

% % Define Fourier operators
% F = @(x) fftshift(fft2(ifftshift(x)));
% Ft = @(x) fftshift(ifft2(ifftshift(x)));
F = @(x) fftshift(fft2(x));
Ft = @(x) ifft2(ifftshift(x));

% define propagation operator, f: input field, h: propagation transfer
% function
% Prop = @(f,h) Ft(F(f).*h);

% N: lateral dimension, Nslice: # of total z-slices
[N,~,Nslice] = size(o_slice); 
% initialize incident field at each slice
phi = zeros(N,N,Nslice);
phi(:,:,1) = i0; % incident field of 1st slice is illumination
% initialize output field at each slice
psi = zeros(N,N,Nslice);
psi(:,:,1) = i0.*o_slice(:,:,1);
for m = 2:Nslice
    if Prop_mode == 0
        H = exp(1i*k2*dz(m-1));
    else
        eva = double(k2<pi/lambda);
        H = exp(-1i*2*pi*sqrt(1/lambda^2-k2/pi/lambda)*dz(m-1)).*eva;
    end
    % propagate from neiboring slices
    phi(:,:,m) = Ft(F(psi(:,:,m-1)).*H);
    % output field = incidence * object
    psi(:,:,m) = phi(:,:,m).*o_slice(:,:,m);
end

% psi(:,:,Nslice) = Prop(psi(:,:,Nslice),H0);

end

