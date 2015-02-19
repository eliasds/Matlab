%%
% 
% Version 1.0
clear all
dirname = '';
filename    = 'DH-';
thlevel=0.4;
erodenum=4; % imerode window, erodes with an nxn matrix
% xcrop=1;
% ycrop=600;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
%numfiles = 400;
%numfiles=10;
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
beadxyz(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
%     Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
%     zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
%     %
%    th = wd_auto(Imin, zmap, thlevel, erodenum, xcrop, ycrop);
    th = wd_auto(Imin, zmap, thlevel, erodenum);
    whiskers(m).time=[th];
    %
    %
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'0_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er.mat'), 'whiskers','-v7.3')

    