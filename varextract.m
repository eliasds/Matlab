function [ output ] = varextract( MatFile, varargin_1 )
%varextract.m Extracts nth variable from '.mat' file
%   Default option will extract first variable from a '.mat' file.
%   Can also speicify which variable to extract.

varnum = 1;
varnam = who('-file',MatFile);

if nargin > 1
    if ischar(varargin_1)
        output = load(MatFile,varargin_1);
        output = output.(varargin_1);
    else
        varnum = varargin_1;
        output = load(MatFile,varnam{varnum});
        output = output.(varnam{varnum});
    end
else
    output = load(MatFile,varnam{varnum});
    output = output.(varnam{varnum});
end
        
end

