function [ O,P ] = GDUpdate_Multiplication(O0,P0,psi,psi0,cen,alpha,beta)
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
% 
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% size of O
No = size(O0); No = No(:);
% size of P, Np<=No
Np = size(P0); Np = Np(:);
cen0 = No/2+1;
r = size(psi,3);

dO = 0;
dP = 0;
for m = 1:r
    % operator to put P at proper location at the O plane
    upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
        ,(No-Np)/2+(cen0-cen(:,m)),'post');
    % operator to crop region of O from proper location at the O plane
    downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
        cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
    dO = dO+upsamp(conj(P0).*(psi(:,:,m)-psi0(:,:,m)));
    dP = dP+downsamp(conj(O0)).*(psi(:,:,m)-psi0(:,:,m));
end

O = O0+alpha/max(abs(P0(:)).^2)*dO;

P = P0+beta/max(abs(O0(:)).^2)*dP;

end

