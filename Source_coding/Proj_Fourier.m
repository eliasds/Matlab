function [ psi, I0 ] = Proj_Fourier( Psi0, I, c )
%PROJ_FOURIER projection based on intensity measurement in the fourier
%domain, replacing the amplitude of the Fourier transform by measured
%amplitude, sqrt(I)
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% % Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));
% F = @(x) fftshift(fft2(x));
% Ft = @(x) ifft2(ifftshift(x));

% intensity estimation give psi0
% Psi0 = F(psi0);
psi0 = Ft(Psi0);

[n1,n2,r] = size(Psi0);

if r == 1
    I0 = abs(psi0).^2;
%     psi = Ft(sqrt(I).*exp(1i*angle(Psi0)));
    psi = F(sqrt(I/c).*exp(1i*angle(psi0)));
else
    I0 = sum(abs(psi0).^2,3);
    psi = zeros(n1,n2,r);
    for m = 1:r
%         psi(:,:,m) = Ft(sqrt(I).*Psi0(:,:,m)./sqrt(I0+eps));
        psi(:,:,m) = F(sqrt(I).*psi0(:,:,m)./sqrt(I0+eps));
    end
end

end

