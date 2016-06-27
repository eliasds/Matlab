% function [ filescopied ] = dropsync( dropboxpath )
%% dropsync - Dropbox Synchronizer
%             Syncronizes current directory with dropbox directory of the
%             same name
%           
%             Daniel Shuldman <elias.ds@gmail.com>
%             Version 0.1

% Author's Default Dropbox Location
defaultdatadir = 'D:\shuldman\data\';
defaultdropboxpath = 'D:\shuldman\dropbox\DH\';

% if nargin < 1
    dropboxpath = defaultdropboxpath;
% end

fullpath = pwd;
[upperpath, currentdir, ~] = fileparts(fullpath);
filesortcurrent = struct2cell(dir(['*.*']))';
filesortcurrent(1:2,:)=[];
[numfilescd, ~] = size(filesortcurrent);
for L = 1:numfilescd
    filesortcurrentcomp(L) = cellstr([filesortcurrent{L,1:2},(num2str(cell2mat(filesortcurrent(L,3:5))))]);
end

dropboxsubpath = upperpath(numel(defaultdatadir):end);
dirnameloc = regexp(dropboxsubpath,'[\\/]');
dropboxsubpath = dropboxsubpath(dirnameloc(1)+1:dirnameloc(2));

dropboxpath = [dropboxpath,'\',dropboxsubpath,'\'];
dropboxpath = [dropboxpath,currentdir,'\'];
dropboxpath = strrep(dropboxpath,'\\','\');
dropboxpath = strrep(dropboxpath,'\\','\');

if ~exist(dropboxpath,'dir')
    mkdir(dropboxpath);
end

filesortdropbox = struct2cell(dir([dropboxpath,'*.*']))';
filesortdropbox(1:2,:)=[];
filesortdropbox(:,4) = num2cell(double(cell2mat(filesortdropbox(:,4))));
[numfilesdb, ~] = size(filesortdropbox);
for L = 1:numfilesdb
    filesortdropboxcomp(L) = cellstr([filesortdropbox{L,1:2},(num2str(cell2mat(filesortdropbox(L,3:5))))]);
end

for
strcmp([filesortdropboxcomp(L)],[filesortcurrent])
% copyfile('*.*',dropboxpath)



% end

