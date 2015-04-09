function [ O, P ] = Proj_Multiplication( psi0, O0,P0, iters, tol )
%PROJ_MULTIPLICATION assume psi = O*P
%   Detailed explanation goes here
% last modified by Lei Tian, lei_tian@alum.mit.edu, 3/1/2014


SE = @(x,y) sum(abs(x(:)-y(:)).^2);

c = 1;
diff = inf;

[n1,n2,r,num] = size(psi0);
psi = zeros(n1,n2,r,num);

while c<iters&&diff>tol
    a = 0;
    b = 0;
    c = 0;
    d = 0;
    for m = 1:r
        p0 = P0(:,:,m);
        for n = 1:m
            a = a+conj(p0).*psi0(:,:,m,n);
            b = b+abs(p0).^2;
            c = c+conj(O0).*psi0(:,:,m,n);
            d = d+abs(O0).^2;
        end
    end
    
    psi = P0.*O0;
    diff = SE(psi,psi0);
    c = c+1;
end


end

