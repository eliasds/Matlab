function [incohbeamIN]=makeincohbeam2D(signal,nummodes,lc,lambda,ps,zpad,perturb)
% make 1D incoherent input beam
% [incohbeamIN]=makeincohbeam(signal,n,nummodes,lc,lambda,ps,zpad,perturb)
% Inputs:   signal - 1D amplitude at input
%           nummodes - number of coherent modes (diffuser patterns) to use
%           lc - spatial coherence width (speckle size) [m]
%           lambda - wavelenght [m]
%           ps - pixel size [m]
%           zpad - number of pixels to pad with (must be larger than
%           length(signal)
%           perturb - small random signal value to be added to mimic noise
%           for modulaiton instability, just set to 0 if not.
% Output: incohbeamIN - a 2D matrix where 1st dimension is the 1D signal
%           spatial dimension and 2nd is the coherent modes dimension
%
% Laura Waller, June 2010, Princeton University, lwaller@alum.mit.edu

[nx,ny]=size(signal);
s=floor(lc/ps)  %number of pixels representing each speckle
sig=0.5*lc/(2*sqrt(2*log(2)));
[sx,sy]=meshgrid((-s*2:s*2)*ps,(-s*2:s*2)*ps);
win=exp(-(sx.^2+sy.^2)/(sig^2));
win=win-min(min(win));win=win/sum(sum(win));

incohbeamIN=ones(nx,ny,nummodes);
for nn=1:nummodes
    diffuser=2*pi*rand(zpad+100,zpad+100)-pi*ones(zpad+100,zpad+100);
    diffuser=conv2(diffuser,win,'same');
    diffuser=diffuser/mean(diffuser(51:end-50));
    diffuser2=exp(-i*pi*(diffuser));
    incohbeamIN(:,:,nn)=diffuser2(51:end-50,51:end-50).*signal+randn(size(signal))*perturb;
end