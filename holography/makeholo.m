%% Function to take input electric field and use Fresnel Propagation
% to output a hologram

function [Holo] = makeholo(Eout)

% Eout = propagate(Ein,lambda,Z,ps,varargin);

Holo = (1+2*real(Eout)+abs(Eout).^2);

% %%
% sizeM=1024;
% mask=ones(sizeM);
% region=round(sizeM*8/16);
% mask(1:region,1:region)=0;
% imagesc(mask)
% circ = getnhood(strel('disk', 5, 4));
% Ein=zeros(1024);
% Ein(509:517,509:517)=circ;
% Ein = 1 - Ein;
% figure; colormap gray; colorbar
% imagesc(Ein); axis image
% figure; colormap gray; colorbar
% imagesc(mask); axis image
% mag = 8;
% ps = 6.5E-6;
% lambda = 632.8E-9;
% Z = 1E-3;
% Eout = propagate(Ein,lambda,Z,ps/mag,'mask',mask);
% figure; colormap gray; colorbar
% imagesc(abs(Eout)); axis image
% Holo = (1+2*real(Eout)+abs(Eout).^2);
% figure; colormap gray; colorbar
% imagesc(Holo); axis image
