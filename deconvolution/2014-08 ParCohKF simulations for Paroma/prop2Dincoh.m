function [field1] = prop2Dincoh(field1,lambda,ztot,ps,zpad,n0)
% propagate a 2D PARTIALLY COHERENT field NONLINEARLY
% function [field1] = prop2Dincoh(field1,lambda,ztot,ps,zpad,n0)
% inputs: field1 - complex field at input plane with dimensions (x,y,modes)
%         lambda - wavelength of light [m]
%         ztot - propagation distance (can be negative)
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
%         n0 - index of refraction of medium
% outputs:field2 - propagated complex field
%
% Laura Waller, Feb 2011, Princeton University, lwaller@alum.mit.edu

[n,m]=size(field1);
nummodes=size(field1,3);
for nn=1:nummodes
        field1(:,:,nn)=propagate(field1(:,:,nn),lambda,ztot/n0,ps,zpad);
end
    