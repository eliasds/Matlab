function [ psi, I0, c ] = Proj_Fourier_Scale( psi0, I, c0, mask, mode )
%PROJ_FOURIER projection based on intensity measurement in the fourier
%domain, replacing the amplitude of the Fourier transform by measured
%amplitude, sqrt(I)
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

%Define Fourier operators
F = @(x) fftshift(fft2(ifftshift(x)));
Ft = @(x) fftshift(ifft2(ifftshift(x)));
vec = @(x) x(mask);

[n1,n2,r] = size(psi0);

% intensity estimation give psi0 & c 
% c is the intensity for each corresponding LED
Zm = zeros(n1,n2,r);
for m = 1:r
    Zm(:,:,m) = c0(m)*abs(F(psi0(:,:,m))).^2;
%     I0 = I0+Zm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adaptive intensity fluctuation correction routine
% c is determined by solving 
%
% [vec(Z1)'vec(Z1) vec(Z2)'vec(Z1) ...                [c1      [vec(Z1)'vec(I)
%                                                  *  ...   =  ...
%  vec(Zr)'vec(Z1) ...             vec(Zr)'vec(Zr)]    cr]     vec(Zr)'vec(I)]  
%
% maybe a 'gradient descent' incremental change approach to take into
% account same c used in multiple measurement?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(mode, 'adaptive')
    Ac = zeros(r);
    bc = zeros(r,1);
    % compute adaptive correction factor
    for k = 1:r
        Zk = vec(Zm(:,:,k));
        bc(k) = Zk'*vec(I);
        for j = 1:r
            Zj = vec(Zm(:,:,j));
            Ac(k,j) = Zk'*Zj;
        end
    end
    c = bc\Ac;
else
    c = c0;
end

I0 = 0;
for m = 1:r
    I0 = I0 + Zm(:,:,m)/c0(m)*c(m);
end

psi = zeros(n1,n2,r);
for m = 1:r
    psi(:,:,m) = Ft(sqrt(I).*F(psi0(:,:,m))./sqrt(I0+eps));
end

end

