%make some fake data for Par coh KF blind deconvolution for Paroma
%L. Waller, Aug 2014, UC Berkeley
%lwaller@alum.mit.edu

clear all; close all; clc

lambda=532e-9;
ps=4*10^(-6);
z=[-10:5:10]*10^-3;
n=2048;
nummodes=10;     %number of coherent modes (speckle patterns)
x=[1:n]*ps;  
%s=1*10^-3;         %source radius (for gaussian, std of source)
f=500*10^-3;        %focal length of condenser
pss=(lambda*f)/(n*ps);
xsource=[1:n]*pss;

obj=ones(n,n);
%obj(21:n-20,21:n-20)=exp(i*pi*phantom(n-40));  %phase object
obj(floor(n/2):floor(n/2)+10,floor(n/2):floor(n/2)+10)=0;
%
tic
%% make source shape (Gaussian) and object
%seff=0.5*s/pss
win=gausswin(n,7);
sourceshape=win*win';

%sourceshape=zeros(n,n);sourceshape(n/2:n/2+(s/pss),n/2:n/2+(s/pss))=1;
%sourceshape=sourceshape-min(min(sourceshape));sourceshape=sourceshape/(n^2*sum(sum(abs(sourceshape.^2))));

%deltax=(s/f)*max(z)

figure;imagesc(xsource,xsource,sourceshape);colorbar;drawnow
illum=ones(n,n,nummodes);
for nn=1:nummodes
    diffuserAmp=rand(n,n);
    
    
    diffuserAmp=ones(size(diffuserAmp));
    
    diffuserPhase=2*pi*rand(n,n)-pi*ones(n,n);
    source=sourceshape.*diffuserAmp.*exp(i*diffuserPhase);
    illum1=fftshift(fft2(source));
    %illum1=illum1/sqrt(mean(mean(abs(illum1.^2))));
    %figure;imagesc(abs(illum1.*obj));colorbar;colormap gray;drawnow
    illum(:,:,nn)=illum1.*obj;
end

illum=illum/sqrt(mean(abs(illum(:).^2)));
toc

%% propagate it.
IntenvZ=zeros(n,n,length(z));
for zn=1:length(z)
    fieldZ=prop2Dincoh(illum,lambda,z(zn),ps,n,1);
    IntenvZ(:,:,zn)=mean(abs(fieldZ.^2),3);
    figure;imagesc(x*10^6,x*10^6,IntenvZ(:,:,zn),[0 2]);colormap gray;colorbar;axis image;drawnow;
    xlabel('microns');ylabel('microns')
    title(sprintf('Intensity at z=%1.1f microns',z(zn)*10^6))
    drawnow
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

    
