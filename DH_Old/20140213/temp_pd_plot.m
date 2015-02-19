%%
% 
% Version 1.0
clc
clear all
dirname = '';
filename    = '1E-5Dilute_';
thlevel=0.4;
erodewin=2; % imerode window, erodes with an nxn matrix
a=0.5E-3;
b=9E-3;
c=860;
radix2=512;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles*10 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
    Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    %
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodewin);
    E1(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'E1')

%%
%%
% 
% Version 1.0
clear all
dirname = '';
filename    = '1E-5Dilute_';
thlevel=0.4;
erodewin=2; % imerode window, erodes with an nxn matrix
a=0.5E-3;
b=9E-3;
c=860;
radix2=512;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles*10 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
    Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    %
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodewin);
    E1(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'E1')
%%
% 
% Version 1.0
clear all
dirname = '';
filename    = '1E-5Dilute_';
thlevel=0.35;
erodewin=2; % imerode window, erodes with an nxn matrix
a=0.5E-3;
b=9E-3;
c=860;
radix2=1024;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles*10 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
    Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    %
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodewin);
    E1(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'E1')

%%
%%
%%
% 
% Version 1.0
clear all
dirname = '';
filename    = '1E-5Dilute_';
thlevel=0.3;
erodewin=1; % imerode window, erodes with an nxn matrix
a=0.5E-3;
b=9E-3;
c=860;
radix2=512;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles*10 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
    Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    %
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodewin);
    E1(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'E1')

%%
% 
% Version 1.0
clear all
dirname = '';
filename    = '1E-5Dilute_';
thlevel=0.4;
erodewin=2; % imerode window, erodes with an nxn matrix
a=0.5E-3;
b=9E-3;
c=860;
radix2=2048;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.mat']);
numfiles = numel(filesort);
load([filesort(1).name]);
[m,n]=size(Imin);
center=round(size(Imin)/2);
tic
%numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for m=1:numfiles*10 % FYI: for loops always reset 'i' values.

    % load data from mat files.
    load([filesort(m).name]);
    % 
    % crop Imin and zmap
    %Center,Center
    Imin=Imin((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    zmap=zmap((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));
    %
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodewin);
    E1(m).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(m/numfiles,wb);
end

close(wb);
toc

save(strcat(filename,'_',num2str(thlevel*100,2),'th_',num2str(erodenum,1),'er',num2str(radix2),'size.mat'), 'E1')