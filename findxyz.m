function [ xyzlocations ] = findxyz( mat )
%findxyz Convert 3D matrix of Logicals to X,Y,Z coordinates
%   Detailed explanation goes here

% mat = round(10*rand(3,4,5));
% mat = mat < 2;

matsize = size(mat);
idxlist = find(mat);

xyzlocations(sum(mat(:)),3) = 0;
for L = 1:length(idxlist)
    xyzlocations(L,3) = ceil(idxlist(L)/(matsize(1)*matsize(2)));
    xyzlocations(L,2) = rem(rem(idxlist(L),(matsize(1)*matsize(2))),matsize(1));
    xyzlocations(L,1) = ceil(rem(idxlist(L),(matsize(1)*matsize(2)))/matsize(1));
end

end


