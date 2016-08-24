function E = Mie_x_radiation(n1, n2, d, lambda, Hsize, dpix, z, digit)
%   INPUTS
%   n1, refractive index of the immersion medium
%   n2, refractive index of the sphere
%   d, diameter of the particle
%   lambda, wavelength of the light in the ambient medium
%   Hsize, Number of pixels of the recorded image
%   z, propagation distance
%   dpix, pixel size
%   digit, precision digit
%
%   OUTPUTS:
%   E = [Ex; Ey; Ez], in Cartesian Coordinates
% last modified by Lei Tian, Dec 15, 2010
% version 3
%   fixed the appoximation in theta. 

%%
% The ONLY approximation is to assume radiating field (kr>>1), which is
% commonly satisfied for visible range.

%%
if nargin == 7
    digit = 4;
end

m = n2/n1;
% wave number
k = 2*pi*n1/lambda;
% size parameter
alpha = 2*pi*n1/lambda*d/2;
% index of refraction
m1=real(m); m2=imag(m);
% coordiates
x = [-ceil(Hsize/2-1)*dpix:dpix:ceil(Hsize/2)*dpix];
[xmesh ymesh] = meshgrid(x);
rmesh = sqrt(xmesh.^2+ymesh.^2);

% azimuthal angle
phi = acos(xmesh./rmesh);
phi(find(rmesh==0)) = 0;
% distance
r = sqrt(rmesh.^2+z^2);
% spherical wave terms
spherical_term = i./(k*r).*exp(i*k*r);
% scattering angle
theta = atan(rmesh/z);
% original scattering angle 
u = cos(theta);
% approximate theta, precision up to 5 digits
thetaapprox = thetaround(theta,digit);
thetacompute = unique(thetaapprox);
% approximated scattering angle u
uapprox = cos(thetaapprox);
ucompute = cos(thetacompute);
num = length(ucompute);

S1 = zeros(Hsize);
S2 = zeros(Hsize);
wb=waitbar(0,'Calculating Mie Series...');
for j = 1:num
    % S12
    S12tmp(j,:) = Mie_S12(m,alpha,ucompute(j));
    idx = find(uapprox==ucompute(j));
    S1(idx) = S12tmp(j,1);
    S2(idx) = S12tmp(j,2);
    waitbar(j/num,wb);
end
close(wb);

% x-polarized light, 
% REF: [1] Ye Pu and Hui Meng, "Intrinsic aberrations due to Mie scattering in
% particle holography," J. Opt. Soc. Am. A 20, 1920-1932 (2003) 
% [2] :/ Tsamg. K. A. Kong, Scattering of Electromagnetic waves
% Ex
E(:,:,1) = spherical_term .* (cos(phi).^2.*u.*S2 +sin(phi).^2.*S1);
% Ey
E(:,:,2) = spherical_term .* (sin(phi).*cos(phi)).*(S2.*u -S1);
% Ez
E(:,:,3) = -spherical_term .* cos(phi).*sin(theta).*S2;





