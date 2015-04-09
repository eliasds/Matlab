function [ c ] = scaling_update( c, I, Z, tau, mode, alpha )
%SCALING_UPDATE Summary of this function goes here
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

vec = @(x) x(:);
% r = # of patches 
r = size(Z,3);

Ac = zeros(r);
bc = zeros(r,1);
I = vec(I);
for k = 1:r
    Zk = vec(Z(:,:,k));
    bc(k) = Zk'*I;
    for j = 1:r
        Zj = vec(Z(:,:,j));
        Ac(k,j) = Zk'*Zj;
    end
end
% Z = vec(Z);
% I = vec(I);

switch mode
    case 'direct'
%         c = Z'*I/(Z'*Z+tau);
        c = bc\(Ac+tau*eye(r));
    case 'newton'
        Z = vec(Z);
        %     alpha = 0.1;
        c = c+alpha/(Z'*Z)*((I-c*Z)'*Z);
    case 'gradient'
        c = c+alpha*((I-c*Z)'*Z);
    case 'average'
        c = mean(I)/mean(Z);
    otherwise
        
end

% Ac = zeros(r);
% bc = zeros(r,1);
% % compute adaptive correction factor
% for k = 1:r
%     Zk = vec(Zm(:,:,k));
%     bc(k) = Zk'*vec(I);
%     for j = 1:r
%         Zj = vec(Zm(:,:,j));
%         Ac(k,j) = Zk'*Zj;
%     end
% end
% c = bc\Ac;
end

