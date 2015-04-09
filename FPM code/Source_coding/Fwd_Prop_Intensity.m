function [ I ] = Fwd_Prop_Intensity( phi0, O, H, H0, Pupil)
%FWD_PROP_MULTISLICE computes the field using multislice approach, with
%propagator H
% inputs:
%   phi0: incident field
%   O: object described in equi-spaced z-slices
%   H: propagator between slices
%   H0: propagator from the final slice to the front focal plane of
%   microscope objective
%   Pupil: pupil function
% outputs:
%   I: intensity

% % Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));
% define propagation operator, f: input field, h: propagation transfer
% function
Prop = @(f,h) Ft(F(f).*h);

% N: lateral dimension, Nslice: # of total z-slices
[N,~,Nslice] = size(O); 

%% multi-slice approach for thick object
% initialize incident field at each slice
phi = zeros(N,N,Nslice);
phi(:,:,1) = phi0; % incident field of 1st slice is illumination
% initialize output field at each slice
psi = zeros(N,N,Nslice);
psi(:,:,1) = phi(:,:,1).*O(:,:,1);
for m = 2:Nslice
    H = exp(1i*k2*dz(m-1));
    % propagate from neiboring slices
    phi(:,:,m) = Prop(psi(:,:,m-1),H);
    % output field = incidence * object
    psi(:,:,m) = phi(:,:,m).*O(:,:,m);
end

psi(:,:,Nslice) = Prop(psi(:,:,Nslice),H0);

%% go through imaging system
Np = size(Pupil);
cen0 = [N/2+1,N/2+1];
downsamp = @(x) x(cen0(1)-Np(1)/2:cen0(1)+Np(1)/2-1,...
    cen0(2)-Np(2)/2:cen0(2)+Np(2)/2-1);

Ohat = F(psi(:,:,Nslice));

I = abs(Ft(downsamp(Ohat).*Pupil)/N^2*Np(1)*Np(2)).^2;


end

