function [ O,P ] = GDUpdate_Multiplication(O0,P0,dpsi,cen,Ps,alpha,beta)
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
% cen0 = round((No+1)/2); %%%
r = size(dpsi,3);

% init guess
O = O0;
P = P0;

% while (it<iters)  
    dO = zeros(No(1),No(2));
%     dO1 = zeros(No(1),No(2));
    dP = 0;
    sumP = zeros(No(1),No(2));
%     sumP2 = sumP;
    sumO = 0;
    for m = 1:r
        % operator to put P at proper location at the O plane
%         upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
%             ,(No-Np)/2+(cen0-cen(:,m)),'post');
%         n1 = (No-Np)/2-(cen0-cen(:,m))+1;
        n1 = cen(:,m)-floor(Np/2);
        n2 = n1+Np-1;
        % operator to crop region of O from proper location at the O plane
        if mod(Np(1),2) == 1
            downsamp = @(x) x(cen(1,m)-(Np(1)-1)/2:cen(1,m)+(Np(1)-1)/2,...
                cen(2,m)-(Np(2)-1)/2:cen(2,m)+(Np(2)-1)/2);
        else
            downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
                cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
        end
%         dO = dO+upsamp(conj(P).*(psi(:,:,m)-psi0(:,:,m)));
%         dP = dP+downsamp(conj(O)).*(psi(:,:,m)-psi0(:,:,m));
%         dO = dO+upsamp(abs(P).*conj(P).*(psi(:,:,m)-psi0(:,:,m)));
        
        dO0 = abs(P).*conj(P).*dpsi(:,:,m);
        dO(n1(1):n2(1),n1(2):n2(2)) = dO(n1(1):n2(1),n1(2):n2(2))+...
            dO0;
        
        O1 = downsamp(O);
        dP = dP+(abs(O1).*conj(O1)).*dpsi(:,:,m);
%         dP = dP+downsamp(abs(O).*conj(O)).*(psi(:,:,m)-psi0(:,:,m));
        
%         sumP = sumP+upsamp(abs(P).^2);
        sumP(n1(1):n2(1),n1(2):n2(2)) = sumP(n1(1):n2(1),n1(2):n2(2))+...
            abs(P).^2;
%         sumO = sumO+downsamp(abs(O).^2);
        sumO = sumO+(abs(O1).^2);
        %         %% fix the spike!
%         cenk = round((Np+1)/2)+cen0-cen(:,m);
%         if abs(cenk(1)-(Np(1)+1)/2)<(Np(1)-1)/2&&abs(cenk(2)-(Np(2)+1)/2)<(Np(2)-1)/2
%             tmp = [dP(cenk(1)-1,cenk(2)),dP(cenk(1)+1,cenk(2)),...
%                 dP(cenk(1),cenk(2)-1),dP(cenk(1),cenk(2)+1)];
%             s = abs(dP(cenk(1),cenk(2)))/mean(abs(tmp));
%             dP(cenk(1),cenk(2)) = dP(cenk(1),cenk(2))/s;
%         end

    end
%     O = O+1/max(abs(P(:)))*dO;
    O = O+1/max(max(abs(P)))*dO./(sumP+alpha);
    P = P+1/max(max(abs(O)))*dP./(sumO+beta).*Ps;
%     P = P+1/max(abs(O(:)))*dP.*Ps;
%     O = O+alpha/max(abs(P(:)).^2)*dO;
%     P = P+beta/max(abs(O(:)).^2)*dP.*Ps;

end

