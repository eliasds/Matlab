function [ matcrop, rect ] = xycrop( mat, rect )
%xycrop 
%   

% matsize = size(mat);
matdims = ndims(mat);

if matdims == 3
    matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)),:);
elseif matdims == 2
    matcrop = mat((rect(2):rect(2)+rect(4)),(rect(1):rect(1)+rect(3)));
else
    error('Matrix Must Have 2 or 3 Dimensions')
end

end
