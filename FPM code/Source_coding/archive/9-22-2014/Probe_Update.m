function P = Probe_Update(O0,P0,psi,cen,beta,Ps)
%GDUPDATE_MULTIPLICATION update estimate of O and P according to gradient
%descent method, where psi = O*P
%   Inputs:
%   O0: object estimate, n1xn2
%   P0: pupil function estimate: m1xm2
%   psi: estimate field patches
%   cen: location of pupil function
%   Ps: support constraint for P0, e.g. spatially confined probe or
%   objective with known NA
%   iters: # of iterations to run on updates
%
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% % size of O
% No = size(O0); No = No(:);
% size of P, Np<=No
Np = size(P0); Np = Np(:);
% cen0 = round((No+1)/2); %%%
% # of patches
Npatch = size(psi,3);

% init guess
O = O0;
% P = P0;

% dO = 0;
% sumP = 0;
% %% step a) update O fixing P and given psi
% for m = 1:Npatch
%     % operator to put P at proper location at the O plane
%     upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
%         ,(No-Np)/2+(cen0-cen(:,m)),'post');
%     dO = dO + upsamp(conj(P).*psi(:,:,m));
%     sumP = sumP + upsamp(abs(P).^2);
%     %         dP = dP+downsamp(conj(O)).*(psi(:,:,m)-psi0(:,:,m));
% end
% 
% O = dO./(sumP+alpha);

%% step b) update P given updated O 
dP = 0;
sumO = 0;
for m = 1:Npatch
    % operator to crop region of O from proper location at the O plane
    if mod(Np(1),2) == 1
        downsamp = @(x) x(cen(1,m)-(Np(1)-1)/2:cen(1,m)+(Np(1)-1)/2,...
            cen(2,m)-(Np(2)-1)/2:cen(2,m)+(Np(2)-1)/2);
    else
        downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
            cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
    end
    dP = dP + downsamp(conj(O)).*psi(:,:,m);
    sumO = sumO + downsamp(abs(O)).^2;
end
P = dP./(sumO+beta);
% considering support constraint
% P = P.*Ps;

end

