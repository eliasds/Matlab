%% Linear Transform of Distance to Optical Path Length
% Version 1.0
%
% function [E1,H] = fp_fresnelprop_gpu(E0,lambda,Z,ps,zpad)
% inputs: E0 - complex field at input plane
%         lambda - wavelength of light [m]
%         Z - vector of propagation distances [m], (can be negative)
%               i.e. "linspace(0,10E-3,500);"
%         ps - pixel size [m]
%         zpad - size of propagation kernel desired
% outputs:E1 - propagated complex field
%         H - propagation kernel to check for aliasing
%
% Daniel Shuldman, UC Berkeley, eliasds@gmail.com
%citations needed
% 
%  sensor           air      quartz    water     quartz     air
%  sensor(z=0)->|<-z1*n1->|<-z2*n2->|<-z3*n3->|<-z4*n4->|<-(n=1)->
%               0        z1        z2        z3        z4
%



function [Zout] = fp_zconvert(Zin,z1,z2,z3,z4,n1,n2,n3,n4)

nair = 1.00027316; % index of refraction for air at 632.8nm

if nargin < 6
    %Constants of setup
    n1   = 1.00027316; % index of refraction for air at 632.8nm
    n2   = 1.5426; % index of refraction for quartz o-ray at 632.8nm
    % n2 = 1.5517; % index of refraction for quartz e-ray at 632.8nm
    n3   = 1.3317; % index of refraction for water at 632.8nm
    n4   = n2;
end

if nargin < 2
    z1   = 0E-3; % 1m of air
    z2   = 1E-3; % 1mm of quartz
    z3   = 11E-3; % 10mm of water
    z4   = 12E-3; % 1mm of quartz
end

Zout=zeros(size(Zin));
Zout(Zin>=z4)        = z1*n1+(z2-z1)*n2+(z3-z2)*n3+(z4-z3)*n4+(Zin(Zin>=z4)-z4)*nair;
Zout(Zin>=z3&Zin<z4) = z1*n1+(z2-z1)*n2+(z3-z2)*n3+(Zin(Zin>=z3&Zin<z4)-z3)*n4;
Zout(Zin>=z2&Zin<z3) = z1*n1+(z2-z1)*n2+(Zin(Zin>=z2&Zin<z3)-z2)*n3;
Zout(Zin>=z1&Zin<z2) = z1*n1+(Zin(Zin>=z1&Zin<z2)-z1)*n2;
Zout(Zin<z1)         = Zin(Zin<z1)*n1;


% 
% Zout=zeros(size(Zin));
% Zout(Zin<z1)         = Zin(Zin<z1)*n1;
% Zout(Zin>=z1&Zin<z2) = z1*n1+(Zin(Zin>=z1&Zin<z2)-z1)*n2;
% Zout(Zin>=z2&Zin<z3) = z1*n1+(z2-z1)*n2+(Zin(Zin>=z2&Zin<z3)-min(Zin(Zin>=z2&Zin<z3)))*n3;
% Zout(Zin>=z3&Zin<z4) = z1*n1+(z2-z1)*n2+(z3-z2)*n3+(Zin(Zin>=z3&Zin<z4)-min(Zin(Zin>=z3&Zin<z4)))*n4;
% Zout(Zin>=z4)        = z1*n1+(z2-z1)*n2+(z3-z2)*n3+(z4-z3)*n4+(Zin(Zin>=z4)-min(Zin(Zin>=z4)))*n5;


