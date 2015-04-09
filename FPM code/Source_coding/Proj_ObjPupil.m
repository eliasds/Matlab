function [ O,P ] = Proj_ObjPupil(O,P,dG,Ps,Omax,alpha,beta)
%GDUPDATE_MULTIPLICATION update estimate of O and P according to gradient
%descent method, where psi = O*P
%   Inputs:
%   O0: object estimate, n1xn2
%   P0: pupil function estimate: m1xm2
%   psi: update estimate field estimate
%   psi0: previous field estimate
%   alpha: gradient descent step size for O
%   betta: gradient descent step size for P
%   Ps: support constraint for P0, e.g. spatially confined probe or
%   objective with known NA
%   iters: # of iterations to run on updates
%
% last modified by Lei Tian, lei_tian@alum.mit.edu, 5/27/2014

% size of O
No = size(O); No = No(:);
% size of P, Np<=No
Np = size(P); Np = Np(:);
cen0 = round((No+1)/2);

% % init guess
% O = O0;
% P = P0;

% dG = G-G0;

% operator to put P at proper location at the O plane
% upsamp = @(x) padarray(x,(No-Np)/2);
% operator to crop region of O from proper location at the O plane
n1 = cen0-floor(Np/2);
n2 = n1+Np-1;
% operator to crop region of O from proper location at the O plane
downsamp = @(x) x(n1(1):n2(1),n1(2):n2(2));

O1 = downsamp(O);

O(n1(1):n2(1),n1(2):n2(2)) = O(n1(1):n2(1),n1(2):n2(2))+ ...
    abs(P).*conj(P)./(abs(P).^2+alpha).*dG/max(max(abs(P)));
% P = P+downsamp(abs(O).*conj(O)./(abs(O).^2+beta)).*dG/max(abs(O(:))).*Ps;
% P = P+abs(O1).*conj(O1)./(abs(O1).^2+beta).*dG/max(max(abs(O))).*Ps;
P = P+abs(O1).*conj(O1)./(abs(O1).^2+beta).*dG/Omax.*Ps;

end

