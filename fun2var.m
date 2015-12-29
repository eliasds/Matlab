function mfile = fun2var( mfname )
%fun2var Summary of this function goes here
%   Detailed explanation goes here

% clear mfile;
% mfname = [mfilename('fullpath'),'.m'];
fileID = fopen(mfname,'r');
q=1;
mfile{q,1} = fgets(fileID);
while ischar(mfile{q,1})
    q=q+1;
    mfile{q,1} = fgets(fileID);
end;
mfile{q,1} = '';
fclose(fileID);

end

