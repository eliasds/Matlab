function [ I ] = Fwd_Intensity( phi0, O, Pupil)
%FWD_PROP_MULTISLICE computes the field using multislice approach, with
%propagator H
% inputs:
%   phi0: incident field
%   O: object described in equi-spaced z-slices
%   microscope objective
%   Pupil: pupil function
% outputs:
%   I: intensity
% N: lateral dimension, Nslice: # of total z-slices
N = size(O,1); 

% % Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));

%% go through imaging system
Np = size(Pupil);
cen0 = [N/2+1,N/2+1];
downsamp = @(x) x(cen0(1)-Np(1)/2:cen0(1)+Np(1)/2-1,...
    cen0(2)-Np(2)/2:cen0(2)+Np(2)/2-1);


I = abs(Ft(downsamp(F(phi0.*O)).*Pupil)).^2;


end

