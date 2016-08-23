%make some fake data for Par coh KF blind deconvolution for Paroma
%L. Waller, Aug 2014, UC Berkeley
%lwaller@alum.mit.edu

clear all; close all; clc

lambda=532e-9;
ps=0.5e-6;
z=[-20:10:20]*10^-6;
n=256;
nummodes=40;     %number of coherent modes (speckle patterns)
x=[1:n]*ps;  
pss=(5*10^-3/n);  %pixel size at source
s=100*10^-4;         %source radius (for gaussian, std of source)
f=100*10^-3;        %focal length of condenser
pscale=pss/ps
pss=lambda*f*ps*pscale;
xsource=[1:n]*pss;

obj=ones(n,n);
%obj(21:n-20,21:n-20)=exp(i*pi*phantom(n-40));  %phase object
obj(floor(n/2)-20:floor(n/2)+2,floor(n/2)-20:floor(n/2)+2)=0;
%
tic
%% make source shape (Gaussian) and object
%seff=s*lambda*f;
alpha=(0.5e-2/s)*(pscale)
win=gausswin(n,alpha);
sourceshape=win*win';sourceshape=sourceshape-min(min(sourceshape));sourceshape=sourceshape/sum(sum(sourceshape));
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
illum=illum/sqrt(mean(mean(mean(abs(illum.^2),3))));
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

%% convolve to get coh beam
%for zn=1:length(z)
