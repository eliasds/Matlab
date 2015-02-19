%%
% 
% Version 1.0

dirname = '';
filename    = 'DH_';
thlevel=0.3;
erodenum=1; % imerode window, erodes with an nxn matrix
radix2=4096;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
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
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodenum);
    beadxyz(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    %
    %
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename(1:end-1),'-',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'beadxyz')

    