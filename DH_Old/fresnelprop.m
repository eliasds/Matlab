%% Fresnel Propagation Function.
% Describes how the image from an object gets propagated in real space.
% Version 2.0

function [] = fresnelprop(ps,lambda,z,objectfile,background)
if nargin < 5
   background = 1;
else
    background=double(imread(background));
%    background(isnan(background)) = 1;
end
gi=double(imread(objectfile))./background;

gi=gi(11:min(size(gi)),11:min(size(gi)));
gi=sqrt(double(gi));
%gi(isnan(gi)) = 0;
N=length(gi);
k=2*pi/lambda; %wavenumber
x=linspace(-ps*N/2,ps*N/2,N); % x-vector
fx=linspace(-1/(ps),1/(ps),N); % x-vector
y=x; %y-vector
fy=fx;
[X,Y]=meshgrid(x,y);
[fX,fY]=meshgrid(fx,fy);
%h=exp(1i*k*z)*exp(1i*k*(X.^2+Y.^2)/(2*z))/(1i*lambda*z); %Fresnel kernel
H=exp(1i*k*z)*exp(-1i*pi*lambda*z*(fX.^2+fY.^2)); %Transfer Function
%tic
Gi=fftshift(fft2(gi));
%H=fftshift(fft2(h));
gf=ifft2(fftshift(Gi.*H));
%toc
%IGi=abs(Gi.^2);
%Igf2=gf2.*conj(gf2);
Igf=abs(gf.^2);
set(0,'DefaultFigureWindowStyle','docked') %Dock all figures
%figure;
colormap(gray)
imagesc(Igf(1:end,1:end));title(strcat('Z= +',num2str(z)),'FontSize',16);
%figure;
%mesh(x,y,IGi)
%figure;
%mesh(x,y,real(H))
%figure;
%mesh(x,y,imag(H))
