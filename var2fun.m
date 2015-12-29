function var2fun( mfile, mfname )
%var2fun Summary of this function goes here
%   Detailed explanation goes here

% clear mname;
fileID = fopen(mfname,'w');
fprintf(fileID,'%s\r',mfile{:});
fclose(fileID);

end

