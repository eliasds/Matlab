function [ psi, I0 ] = Proj_Fourier( psi0, I )
%PROJ_FOURIER projection based on intensity measurement in the fourier
%domain, replacing the amplitude of the Fourier transform by measured
%amplitude, sqrt(I)
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

%Define Fourier operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));
% intensity estimation give psi0
I0 = sum(abs(F(psi0)).^2,3);

[n1,n2,r] = size(psi0);

psi = zeros(n1,n2,r);

for m = 1:r
    psi(:,:,m) = Ft(sqrt(I).*F(psi0(:,:,m))./sqrt(I0));
end

end

