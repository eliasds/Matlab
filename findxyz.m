function [ xyzlocations ] = findxyz( mat, Holo )
%findxyz Convert either indexed list or 3D matrix of Logicals to X,Y,Z coordinates
%   Outputs an n by 3 matrix where column one is the x coordinate, column
%   two is the y coordinate, and so on... If you add the Holo input, there
%   will an extra column with the value of Holo at coodinate (x,y,...) 
%   

% mat = round(10*rand(3,4,5));
% mat = mat < 2;

if isvector(mat) || isscalar(mat)
    idxlist = mat;
    matsize = Holo;
else
    idxlist = find(mat);
    matsize = size(mat);
end

xyzlocations(sum(mat(:)),3) = 0; % makes colums for x,y,z coordinates
for L = 1:length(idxlist)
    if ndims(mat) > 2
        xyzlocations(L,3) = ceil(idxlist(L)/(matsize(1)*matsize(2)));
    end
    xyzlocations(L,2) = rem(rem(idxlist(L),(matsize(1)*matsize(2))),matsize(1));
    xyzlocations(L,1) = ceil(rem(idxlist(L),(matsize(1)*matsize(2)))/matsize(1));
end
if exist('Holo','var') 
    matdims = ndim(Holo);
    for L = 1:length(xyzlocations)
        xyzlocations(L,matdims+1) = Holo(xyzlocations(L,2),xyzlocations(L,1),xyzlocations(L,3));
    end
end

end

