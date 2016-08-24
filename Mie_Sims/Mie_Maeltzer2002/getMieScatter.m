function musgp = getMieScatter(lambda, dia, fv, npar,nmed)
% function musgp = getMieScatter(lambda, dia, fv)
%  fv            = volume fraction of spheres in medium (eg., fv = 0.05)
%  lambda        = wavelength in um (eg., lambda = 0.633)
%  dia           = sphere diameter in um (eg., dia_um = 0.0500)
%  npar          = particle refractive index (eg. polystyrene = 1.57)
%  nmed          = medium refractive index (eg., water = 1.33)
%                  Note: npar and nmed can be imaginary numbers.
%  returns musgp = [mus g musp]  
%       mus      = scattering coefficient [cm^-1]
%       g        = anisotropy of scattering [dimensionless]
%       musp     = reduced scattering coefficient [cm^-1]
%  Uses
%       Mie.m, which uses mie_abcd.m, from Maetzler 2002
%       
% - Steven Jacques, 2009

Vsphere = 4/3*pi*(dia/2)^3;     % volume of sphere
rho     = fv/Vsphere;           % #/um^3, concentration of spheres

m = npar/nmed;                  % ratio of refractive indices
x = pi*dia/(lambda/nmed);       % ratio circumference/wavelength in medium

u = Mie(m, x)';                 % <----- Matlzer's subroutine
% u = [real(m) imag(m) x qext qsca qabs qb asy qratio];

qsca = u(5);                    % scattering efficiency, Qsca
g    = u(8);                    % anisotropy, g

A       = pi*dia^2/4;           % geometrical cross-sectional area, um^2
sigma_s = qsca*A;               % scattering cross-section, um^2
mus     = sigma_s*rho*1e4;      % scattering coeff. cm^-1
musp    = mus*(1-g);            % reduced scattering coeff. cm^-1

if 1 % 1 = print full report, 0 = disable
    disp('----- choice:')
    disp(sprintf('lambda  \t= %0.3f um', lambda))
    disp(sprintf('dia     \t= %0.3f um', dia))
    disp(sprintf('rho     \t= %0.3f #/um^3', rho))
    disp(sprintf('npar    \t= %0.3f', npar))
    disp(sprintf('nmed    \t= %0.3f', nmed))
    disp('----- result:')
    disp(sprintf('real(m) \t= %0.3f', u(1)))
    disp(sprintf('imag(m) \t= %0.3e', u(2)))
    disp(sprintf('x       \t= %0.3e', u(3)))
    disp(sprintf('qext    \t= %0.3e', u(4)))
    disp(sprintf('qsca    \t= %0.3e', u(5)))
    disp(sprintf('qabs    \t= %0.3e', u(6)))
    disp(sprintf('qb      \t= %0.3e', u(7)))
    disp(sprintf('asy     \t= %0.4f', u(8)))
    disp(sprintf('qratio  \t= %0.3e', u(9)))
    disp('----- optical properties:')
    disp(sprintf('mus     \t= %0.3f cm^-1', mus))
    disp(sprintf('g       \t= %0.4f', g))
    disp(sprintf('musp    \t= %0.3f cm^-1', musp))
end

musgp= real([mus g musp]);

