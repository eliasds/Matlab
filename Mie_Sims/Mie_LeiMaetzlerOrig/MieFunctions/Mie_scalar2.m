function E = Mie_scalar2(m, d, lambda, Hsize, dpix, z, digit)
%   INPUTS
%   m, refractive index of the particle
%   d, diameter of the particle
%   lambda, wavelength of the light in the ambient medium
%   Hsize, Number of pixels of the recorded image
%   z, propagation distance
%   dpix, pixel size
%   digit, precision digit
%
%   OUTPUTS:
%   E = [Ex; Ey; Ez], in Cartesian Coordinates
% last modified by Lei Tian, Nov 23, 2010
% version 2
if nargin == 6
    digit = 6;
end

% wave number
k = 2*pi/lambda;
% size parameter
alpha = 2*pi/lambda*d/2;
% index of refraction
m1=real(m); m2=imag(m);
% coordiates
x = [-ceil(Hsize/2-1)*dpix:dpix:ceil(Hsize/2)*dpix];
[xmesh ymesh] = meshgrid(x);
rmesh = sqrt(xmesh.^2+ymesh.^2);

% azimuthal angle
phi = acos(xmesh./rmesh);
phi(512,512) = 0;
% distance
r = sqrt(rmesh.^2+z^2);
% spherical wave terms
spherical_term = i./(k*r).*exp(i*k*r);
% scattering angle
theta = atan(rmesh/z);
u = cos(theta);
% precision up to 5 digit
uapprox = roundp(u,digit);
ucompute = unique(uapprox);

S1 = zeros(Hsize);
S2 = zeros(Hsize);
for j = 1:length(ucompute)
    % S12
    S12tmp(j,:) = Mie_S12(m,alpha,ucompute(j));
    idx = find(uapprox==ucompute(j));
    S1(idx) = S12tmp(j,1);
    S2(idx) = S12tmp(j,2);
end

% x-polarized light, 
% REF: [1] Ye Pu and Hui Meng, "Intrinsic aberrations due to Mie scattering in
% particle holography," J. Opt. Soc. Am. A 20, 1920-1932 (2003) 
% [2] :/ Tsamg. K. A. Kong, Scattering of Electromagnetic waves
% Ex
E(:,:,1) = spherical_term .* (-cos(phi).^2.*u.*S2 -sin(phi).^2.*S1);
% Ey
E(:,:,2) = spherical_term .* (sin(phi).*cos(phi)).*(-S2.*u +S1);
% Ez
E(:,:,3) = spherical_term .* cos(phi).*sin(theta).*S2;





