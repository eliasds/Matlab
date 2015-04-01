function [ xyzlocations ] = findxyz( mat, varargin )
%findxyz Convert either indexed list or 3D matrix of Logicals to X,Y,Z coordinates
%   Outputs an n by 3 matrix where column one is the x coordinate, column
%   two is the y coordinate, and so on... If you add the Holo input, there
%   will an extra column with the value of Holo at coodinate (x,y,...) 
%   

xycrop = false;

while ~isempty(varargin)
    switch upper(varargin{1})
        
        case 'HOLO'
            Holo = [(varargin{2})];
            varargin(1:2) = [];
            
        case 'XYCROP'
            rect = [(varargin{2})];
            xycrop = true;
%             rect = [1550-512,2070-1024,1023,1023];
            varargin(1:2) = [];
            
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

if isvector(mat) || isscalar(mat)
    idxlist = mat;
    matsize = size(Holo);
    matdims = ndims(Holo);
else
    idxlist = find(mat);
    matsize = size(mat);
    matdims = ndims(mat);
end
numpart = length(idxlist);

if xycrop == false
    rect = [1,1,matsize(2),matsize(1)];
end

xyzlocations(numpart,3) = 0; % makes colums for x,y,z coordinates
for L = 1:numpart
    if matdims > 2
        xyzlocations(L,3) = ceil(idxlist(L)/(matsize(1)*matsize(2)));
    end
    xyzlocations(L,2) = rem(rem(idxlist(L),(matsize(1)*matsize(2))),matsize(1));
    xyzlocations(L,1) = ceil(rem(idxlist(L),(matsize(1)*matsize(2)))/matsize(1));
end

if exist('Holo','var') 
    for L = 1:numpart
        xyzlocations(L,matdims+1) = Holo(xyzlocations(L,2),xyzlocations(L,1),xyzlocations(L,3));
    end
end

xyzlocations(:,2) = xyzlocations(:,2) + rect(2) - 1;
xyzlocations(:,1) = xyzlocations(:,1) + rect(1) - 1;

end


