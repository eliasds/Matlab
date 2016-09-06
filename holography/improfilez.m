function [zprofile, Z] = improfilez( img, ncent, mcent, z1, z2, zstepsize, lambda, ps, zpad, mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% check the length of mcent and ncent are equal
if length(mcent) ~= length(ncent)
    error('Use the same number of x-pixels and y-pixels')
end

% allocate zprofile
Z = (z1:zstepsize:z2);
zprofile = zeros(numel(Z),numel(mcent));

% propagate to all Zs and save pixel values at coresponding ncent,mcent
multiWaitbar('Recording Z Profile...',0);
for La = 1:numel(Z)
    Ez = propagate(img,lambda,Z(La),ps,'zpad',zpad,'mask',mask);
    for Lb = 1:numel(mcent)
        zprofile(La,Lb) = Ez(mcent(Lb),ncent(Lb));
    end
    multiWaitbar('Recording Z Profile...',La/numel(Z));
end

multiWaitbar('closeall');
