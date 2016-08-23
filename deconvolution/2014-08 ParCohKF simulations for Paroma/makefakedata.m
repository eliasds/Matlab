%make some fake data for Par coh KF blind deconvolution for Paroma
%L. Waller, Aug 2014, UC Berkeley
%lwaller@alum.mit.edu

clear all; close all; clc

lambda=532e-9;
ps=0.5e-6;
z=[-25:5:25]*10^-6;
n=256;
nummodes=5000;    %number of coherent modes (speckle patterns)
lc=100e-6;       %coherence length
x=[1:n]*ps;     

tic
%% make an incoherent beam
obj=ones(n,n);
obj(21:n-20,21:n-20)=exp(i*pi*phantom(n-40));  %phase object
illum=makeincohbeam2D(obj,nummodes,lc,lambda,ps,n,0);

IntenvZ=zeros(n,n,length(z));
for zn=1:length(z)
    fieldZ=prop2Dincoh(illum,lambda,z(zn),ps,n,1);
    IntenvZ(:,:,zn)=mean(abs(fieldZ.^2),3);
    figure;imagesc(x*10^6,x*10^6,IntenvZ(:,:,zn),[0 2]);colormap gray;colorbar;axis image;drawnow;
    xlabel('microns');ylabel('microns')
    title(sprintf('Intensity at z=%1.1f microns',z(zn)*10^6))
    toc
end

%% make an coherent beam

IntenvZcoh=zeros(n,n,length(z));
for zn=1:length(z)
    [fieldZ,H]=propagate(obj,lambda,z(zn),ps,n);
    IntenvZcoh(:,:,zn)=abs(fieldZ.^2);
    figure;imagesc(x*10^6,x*10^6,IntenvZcoh(:,:,zn),[0 2]);colormap gray;colorbar;axis image;drawnow;
    xlabel('microns');ylabel('microns')
    title(sprintf('coherent Intensity at z=%1.1f microns',z(zn)*10^6))
    toc
end

figure;imagesc(real(H));colorbar


