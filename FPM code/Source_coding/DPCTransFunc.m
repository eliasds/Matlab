function [ Hr, Hi ] = DPCTransFunc( P, S )
%DPCTRANSFUNC computes the phase transfer function of DPC given the source
%distribution
%   Theory: 
%   H_real(u) = -[\int S(u')P^*(u')P(u'+u)du'+\int S(u')P(u')P^*(u'-u)du']
%             = -2*Ft(Real(F(S*P)^*.*F(P)))
%   H_img(u) = i[\int S(u')P^*(u')P(u'+u)du'-\int S(u')P(u')P^*(u'-u)du']
%            = -2*Ft(imag(F(S*P)^*.*F(P)))
% outputs:
%   Hr: transfer function of real part
%   Hi: transfer function of imag part
%
% inputs
%   P: pupil function
%   S: source function

% Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));

FSPc = conj(F(S.*P));
FP = F(P);

Hr = -2*Ft(real(FSPc.*FP));
Hi = -2*Ft(imag(FSPc.*FP));

Htot = sqrt(abs(Hr).^2+abs(Hi).^2);
Htotmax = max(max(Htot));
Hr = Hr./Htotmax;
Hi = Hi./Htotmax;

end

