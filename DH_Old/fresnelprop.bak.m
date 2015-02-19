%% Fresnel Propagation code.
%Describes how the image from an object gets propagated in real space.

%% Clear all data and figures.
%
clf %clears figures
close all %close figures
%clear all %clears workspace variables
set(0,'DefaultFigureWindowStyle','docked') %Dock all figures

%% Parameters
%
N=1024; %number of pixels
gi=zeros(N,N); gi(:,round(N/2-50))=1; gi(:,round(N/2+50))=1; %double slit object matrix (z=0)
%gi=sqrt(phantom(N)); %double slit object matrix (z=0)
lambda=633e-9; %wavelength
k=2*pi/lambda; %wavenumber
ps=1e-6; %pixel size in meters
z=2e-2; %z value for output image in meters
x=linspace(-ps*N/2,ps*N/2,N); % x-vector
fx=linspace(-1/(ps),1/(ps),N); % x-vector
y=x; %y-vector
fy=fx;
[X,Y]=meshgrid(x,y);
[fX,fY]=meshgrid(fx,fy);

%% Import Data
%

%% Fresnel Kernel
%
%h=exp(1i*k*z)*exp(1i*k*(X.^2+Y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
H=exp(1i*k*z)*exp(-1i*pi*lambda*z*(fX.^2+fY.^2)); %Transfer Function

%% Fourier Transform Method
%
tic
Gi=fftshift(fft2(gi));
%H=fftshift(fft2(h));
gf=ifft2(fftshift(Gi.*H));
toc
%IGi=abs(Gi.^2);
%Igf2=gf2.*conj(gf2);
Igf=abs(gf.^2);
%% Plot Figures
%
figure;
colormap(bone)
imagesc(Igf)
%figure;
%mesh(x,y,IGi)
%figure;
%mesh(x,y,real(H))
%figure;
%mesh(x,y,imag(H))
