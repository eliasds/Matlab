function [ psi, I0, c ] = Proj_Fourier_Adaptive( psi0, I, mask, mode )
%PROJ_FOURIER projection based on intensity measurement in the fourier
%domain, replacing the amplitude of the Fourier transform by measured
%amplitude, sqrt(I)
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% % Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));
% F = @(x) fftshift(fft2(x));
% Ft = @(x) ifft2(ifftshift(x));

Psi0 = Ft(psi0);
I0 = sum(abs(Psi0).^2,3);

[n1,n2,r] = size(psi0);

% adaptive intensity fluctuation correction routine
switch mode
    case 'nonadaptive'
        c = 1;
    case 'adaptive'
        c = mean(I0(mask))/mean(I(mask));
        I = c*I;
end

if r == 1
%     I0 = abs(Psi0).^2;
%     psi = Ft(sqrt(I).*exp(1i*angle(Psi0)));
    psi = F(sqrt(I).*exp(1i*angle(Psi0)));
else
    psi = zeros(n1,n2,r);
    for m = 1:r
%         psi(:,:,m) = Ft(sqrt(I).*Psi0(:,:,m)./sqrt(I0+eps));
        psi(:,:,m) = F(sqrt(I).*Psi0(:,:,m)./sqrt(I0+eps));
    end
end

end

