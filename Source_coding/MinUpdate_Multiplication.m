function [ O,P ] = MinUpdate_Multiplication(O0,P0,psi,cen,Ps,iters)
%MinUpdate_Multiplication update estimate of O and P according to
%minimizing the least square. Only pixels defined by the support Ps in O
%will be updated, the same spatial support constraints is applied to update
%P
%   Inputs: 
%   O0: object estimate, n1xn2
%   P0: pupil function estimate: m1xm2
%   psi: update estimate field estimate
%   psi0: previous field estimate
%   cen: location of pupil function
%   Ps: support constraint for P0, e.g. spatially confined probe or
%   objective with known NA
%   iters: # of iterations to run on updates
% 
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014

% size of O
No = size(O0); No = No(:);
% size of P, Np<=No
Np = size(P0); Np = Np(:);
cen0 = No/2+1;
r = size(psi,3);

% init guess
O = O0;
P = P0;
%psi = psi0;
it = 0;

while (it<iters)
    % initilization
    wO = 0;
    wP = 0;
    Ot = 0;
    Pt = 0;
    for m = 1:r
        % operator to put P at proper location at the O plane
        upsamp = @(x) padarray(padarray(x,(No-Np)/2-(cen0-cen(:,m)),'pre')...
            ,(No-Np)/2+(cen0-cen(:,m)),'post');
        % operator to crop region of O from proper location at the O plane
        downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
            cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
        
        Ot = Ot+upsamp(conj(P).*psi(:,:,m).*Ps);
        Pt = Pt+downsamp(conj(O)).*psi(:,:,m).*Ps;
        wO = wO+upsamp(abs(P).^2.*Ps);
        wP = wP+abs(downsamp(O)).^2;
    end
    
    idxO = find(wO);
    O(idxO) = Ot(idxO)./wO(idxO);
    idxP = find(Ps);
    P(idxP) = Pt(idxP)./(wP(idxP)+eps);
    
%     for m = 1:r
%         % operator to crop region of O from proper location at the O plane
%         downsamp = @(x) x(cen(1,m)-Np(1)/2:cen(1,m)+Np(1)/2-1,...
%             cen(2,m)-Np(2)/2:cen(2,m)+Np(2)/2-1);
%         psi(:,:,m) = downsamp(O).*P;
%     end
%     
    
    it = it+1;
end

end

