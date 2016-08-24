function E = Mie_scalar(m, d, lambda, Hsize, dpix, z)
%   INPUTS
%   m, refractive index of the particle
%   d, diameter of the particle
%   lambda, wavelength of the light in the ambient medium
%   Hsize, Number of pixels of the recorded image
%   z, propagation distance
%   dpix, pixel size
%
%   OUTPUTS: 
%   E = [Ex; Ey; Ez], in Cartesian Coordinates
% last modified by Lei Tian, Nov 23, 2010

k = 2*pi/lambda;

% size parameter
alpha = 2*pi/lambda*d/2;
% index of refraction
m1=real(m); m2=imag(m);
% coordiates
x = [-ceil(Hsize/2-1)*dpix:dpix:ceil(Hsize/2)*dpix];
[xmesh ymesh] = meshgrid(x);
rmesh = sqrt(xmesh.^2+ymesh.^2);


for j = 1:Hsize    
    for k = 1:Hsize
        % scattering angle
        theta = atan(rmesh(k,j)/z);
        u=cos(theta);
        % S12
        S12 = Mie_S12(m,alpha,u);
        % azimuthal angle
        phi = acos(xmesh(k,j)/rmesh(k,j));
        
        % distance
        r = sqrt(rmesh(k,j)^2+z^2);
        % spherical wave terms
        spherical_term = i/(k*r)*exp(i*k*r);
        % Ex
        E(k,j,1) = -spherical_term * (sin(phi)*cos(phi))*(S12(2)*cos(theta)-S12(1));
        % Ey
        E(k,j,2) = spherical_term * (cos(phi)^2*cos(theta)*S12(2)+sin(phi)^2*S12(1));
        % Ez
        E(k,j,3) = -spherical_term * cos(phi)*sin(theta)*S12(2);
    end
end






