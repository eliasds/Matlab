function O = Object_Update(O0,P0,psi,psi0,cen,alpha,iters)
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

% size of O
No = size(O0); No = No(:);
% size of P, Np<=No
Np = size(P0); Np = Np(:);
cen0 = round((No+1)/2); %%%
r = size(psi,3);

% init guess
O = O0;
P = P0;
it = 0;

while (it<iters)  
    dO = 0;
%     dP = 0;
%     sumP = 0;
%     sumO = 0;
    for m = 1:r
        % operator to put P at proper location at the O plane
        upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
            ,(No-Np)/2+(cen0-cen(:,m)),'post');
        % operator to crop region of O from proper location at the O plane
%         if mod(Np(1),2) == 1
%             downsamp = @(x) x(cen(1,m)-(Np(1)-1)/2:cen(1,m)+(Np(1)-1)/2,...
%                 cen(2,m)-(Np(2)-1)/2:cen(2,m)+(Np(2)-1)/2);
%         else
%             downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
%                 cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
%         end
%         dO = dO+upsamp(conj(P).*(psi(:,:,m)-psi0(:,:,m)));
%         dP = dP+downsamp(conj(O)).*(psi(:,:,m)-psi0(:,:,m));
        dO = dO+upsamp(abs(P).*conj(P)./(abs(P).^2+alpha).*(psi(:,:,m)-psi0(:,:,m)));
%         dP = dP+downsamp(abs(O).*conj(O)./(abs(O).^2+beta)).*(psi(:,:,m)-psi0(:,:,m));
%         %% fix the spike!
%         cenk = round((Np+1)/2)+cen0-cen(:,m);
%         if abs(cenk(1)-(Np(1)+1)/2)<(Np(1)-1)/2&&abs(cenk(2)-(Np(2)+1)/2)<(Np(2)-1)/2
%             tmp = [dP(cenk(1)-1,cenk(2)),dP(cenk(1)+1,cenk(2)),...
%                 dP(cenk(1),cenk(2)-1),dP(cenk(1),cenk(2)+1)];
%             s = abs(dP(cenk(1),cenk(2)))/mean(abs(tmp));
%             dP(cenk(1),cenk(2)) = dP(cenk(1),cenk(2))/s;
%         end

    end
    O = O+1/max(abs(P(:)))*dO;
%     P = P+1/max(abs(O(:)))*dP.*Ps;
%     O = O+alpha/max(abs(P(:)).^2)*dO;
%     P = P+beta/max(abs(O(:)).^2)*dP.*Ps;
    it = it+1;
end

end

