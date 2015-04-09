function [ I ] = illumination_pattern_intensity( obj, Ns, Pupil, scale, Np, mode)
%LPFIMAGE Computes the output image low-pass filtered by limited NA
%   OBJ: input spectrum
%   Ns = [Nsx,Nsy]: centers of corresponding lpf regions for
%   the illumination pattern
%   Pupil: lpf function defined by the pupil function
%   scale: intensity for each patch
%   Nm = [N_mx,N_my]: output intensity size
%

% added intensity non-uniformity factor
% compute from spatial domain to allow sub-pixel shift corresponding to LED
% locations
% last modified 4/18/2014
% by Lei Tian, lei_tian@berkeley.edu


% %Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));
% F = @(x) fftshift(fft2(x));
% Ft = @(x) ifft2(ifftshift(x));

% Assumes N_m is even
[n1,n2] = size(obj);



if strcmp(mode, 'fourier')
    % operator to crop region of O from proper location at the O plane
    if mod(Np(1),2) == 1
        cen0 = [(n1+1)/2,(n2+1)/2];
        downsamp = @(x,Ns) x(cen0(1)-Ns(1)-(Np(1)-1)/2:cen0(1)-Ns(1)+(Np(1)-1)/2,...
            cen0(2)-Ns(2)-(Np(2)-1)/2:cen0(2)-Ns(2)+(Np(2)-1)/2);
    else
        cen0 = [n1/2+1,n2/2+1];
        downsamp = @(x,Ns) x(cen0(1)-Ns(1)-Np(1)/2:cen0(1)-Ns(1)+Np(1)/2-1,...
            cen0(2)-Ns(2)-Np(2)/2:cen0(2)-Ns(2)+Np(2)/2-1);
    end
    crop = @(c,Ns) downsamp(c*obj,Ns);
elseif strcmp(mode, 'spatial')
    if mod(n1,2) == 1
        u = [-1/2:1/(n2-1):1/2];
        v = [-1/2:1/(n1-1):1/2];
    else
        u = [-1/2:1/n2:1/2-1/n2];
        v = [-1/2:1/n1:1/2-1/n1];
    end
    [u,v] = meshgrid(u,v);
    % operator to crop region of O from proper location at the O plane
    if mod(Np(1),2) == 1
        cen0 = [(n1+1)/2,(n2+1)/2];
        downsamp = @(x) x(cen0(1)-(Np(1)-1)/2:cen0(1)+(Np(1)-1)/2,...
            cen0(2)-(Np(2)-1)/2:cen0(2)+(Np(2)-1)/2);
    else
        cen0 = [n1/2+1,n2/2+1];
        downsamp = @(x) x(cen0(1)-Np(1)/2:cen0(1)+Np(1)/2-1,...
            cen0(2)-Np(2)/2:cen0(2)+Np(2)/2-1);
    end
%     crop = @(c,Ns) downsamp(c*Ft(obj.*exp(-1i*2*pi*(u*Ns(2)+v*Ns(1)))));
    crop = @(c,Ns) downsamp(c*F(obj.*exp(-1i*2*pi*(u*Ns(2)+v*Ns(1)))));
end


% shift due to LED's finite size, assume N_led is always odd,
% since the coherent limit should always correspond to Ns_led = 0 and
% N_led = 1
r = size(Ns,1);
I = 0;
for p = 1:r
    %     cen = [n1/2+1,n2/2+1]+[Ns(p,1),Ns(p,2)];
    %     S = OBJ(cen(2)-Np(2)/2:cen(2)+Np(2)/2-1,cen(1)-Np(1)/2:cen(1)+Np(1)/2-1);
    
    % physically acquired spectrum after lpf
    %     psi = downsamp(obj,cen).*Pupil;
    %     psi = downsamp(scale(p)*Ft(obj.*exp(-1i*2*pi*(u*Ns(2)+v*Ns(1))))).*Pupil;
    psi = crop(sqrt(scale(p)),Ns(p,:)).*Pupil;
    
%     I = I+abs(F(psi)/n1/n2*Np(1)*Np(2)).^2;
    I = I+abs(Ft(psi)/n1/n2*Np(1)*Np(2)).^2;
end

% % not necessary, but make the normalization consistant to throw in a
% % constant factor 1/N_led^2 everywhere
% I = I/N_led^2;

end

