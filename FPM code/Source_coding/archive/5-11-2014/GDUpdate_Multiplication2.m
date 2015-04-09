function [ O,P ] = GDUpdate_Multiplication2(O0,P0,psi,psi0,Ns,Ps,alpha,beta,iters)
%GDUPDATE_MULTIPLICATION update estimate of O and P according to gradient
%descent method, where psi = O*P
%   Inputs: 
%   O0: object estimate, n1xn2
%   P0: pupil function estimate: m1xm2
%   psi: update estimate field estimate
%   psi0: previous field estimate
%   cen: location of pupil function
%   alpha: gradient descent step size for O
%   betta: gradient descent step size for P
%   Ps: support constraint for P0, e.g. spatially confined probe or
%   objective with known NA
%   iters: # of iterations to run on updates
% 
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% Fourier Transform operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));

% size of O
No = size(O0); No = No(:);
% size of P, Np<=No
Np = size(P0); Np = Np(:);
cen0 = No/2+1; %%%
r = size(psi,3);
u = [-1/2:1/No(2):1/2-1/No(2)];
v = [-1/2:1/No(1):1/2-1/No(1)];
[u,v] = meshgrid(u,v);

% define opeators
shift = @(x,s) Ft(F(x).*exp(1i*2*pi*(s(2)*u+s(1)*v)));
crop = @(x) x(cen0(1)-Np(1)/2:cen0+Np(1)/2-1,cen0(2)-Np(2)/2:cen0+Np(2)/2-1);
upsamp = @(x,s) shift(padarray(x,[(No-Np)/2]),s);
downsamp = @(x,s) crop(shift(x,s));

% init guess
O = O0;
P = P0;
it = 0;

while (it<iters)  
    dO = 0;
    dP = 0;
    for m = 1:r
        % operator to put P at proper location at the O plane
%         upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
%             ,(No-Np)/2+(cen0-cen(:,m)),'post');
        % operator to crop region of O from proper location at the O plane
%         downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
%             cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
%         dO = dO+upsamp(conj(P).*(psi(:,:,m)-psi0(:,:,m)));
%         dP = dP+downsamp(conj(O)).*(psi(:,:,m)-psi0(:,:,m));

        % compute the support for shifted pupil to eliminate dft leakage
        % defines the region in O will be updated
        Pshift = upsamp(P,-Ns(:,m));
        Pshift = double(abs(Pshift)>.2);
        dO = dO+upsamp(conj(P).*(psi(:,:,m)-psi0(:,:,m)),-Ns(:,m)).*Pshift;
        dP = dP+downsamp(conj(O),Ns(:,m)).*(psi(:,:,m)-psi0(:,:,m));

    end
    
    O = O+alpha/max(abs(P(:)).^2)*dO;
    P = P+beta/max(abs(O(:)).^2)*dP.*Ps;

    it = it+1;
end

end

