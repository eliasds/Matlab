function [E,Ex,Ey,Ez] = MieField(n1, n2, d, lambda, Hsize, dpix, Z, cen, digit)
%MieField creates a simulated electric field from Mie scattering particles.
%   The ONLY approximation is to assume radiating field (kr>>1), which is
%   commonly satisfied for visible range.
%
%   INPUTS
%   n1, refractive index of the immersion medium
%   n2, refractive index of the sphere
%   d, diameter of the particle
%   lambda, wavelength of the light in the ambient medium
%   Hsize, Number of pixels of the recorded image
%   Z, propagation distance
%   dpix, pixel size
%   cen: center of the particle (units: pixels)
%   digit, precision digit
%
%   OUTPUTS:
%   E = [Ex; Ey; Ez], in Cartesian Coordinates
%
%   Version 7
%   11/30/2015, Daniel Shuldman
%   First attempt to remove aliasing due to
%   spatial frequency greater than 1/(2 pixels)
%
%%
if nargin == 7
    digit = 4;
end

m = n2/n1;
% wave number
k = 2*pi*n1/lambda;
% size parameter
alpha = k*d/2;
% index of refraction
m1=real(m); m2=imag(m);
% coordiates
x = [-ceil(Hsize/2-1)*dpix:dpix:ceil(Hsize/2)*dpix]+cen(1)*dpix;
y = [-ceil(Hsize/2-1)*dpix:dpix:ceil(Hsize/2)*dpix]+cen(2)*dpix;
[xmesh, ymesh] = meshgrid(x,y);
rmesh = sqrt(xmesh.^2+ymesh.^2);

% azimuthal angle
phi = acos(xmesh./rmesh);
%remove NaN's
phi(rmesh==0) = 0;
% distance
r = sqrt(rmesh.^2+Z^2);
% spherical wave terms
spherical_term = 1i./(k*r).*exp(1i*k*r);
% scattering angle
theta = atan(rmesh/Z);

% Remove Aliasing - create a maximum scattering angle to meet Nyquist Limits
min_integer = ceil(k*Z/pi);
all_integers = (min_integer:min_integer+9999);
all_ring_pos = [0,sqrt((all_integers*pi/k).^2 - Z^2)];
all_delta_rings = diff(all_ring_pos);
max_rings = sum(all_delta_rings/2 > dpix)+1;
try
    max_ring_pos = max(all_ring_pos(max_rings),d/2);
catch
    max_ring_pos = d;
end
thetamax = atan(max_ring_pos/Z);
theta(theta>thetamax) = pi/2;
disp(['Number of Nyquist Limited Diffraction Rings: ',num2str(max_rings)]);
disp(['Maximum Scattering Radius and Angle: ',num2str(max_ring_pos),' & ',num2str(thetamax)]);

% original scattering angle 
u = cos(theta);
% u(abs(u)<1E-4) = 0; % Make Cosines of Pi/2 = 0;
% approximate theta, precision up to 5 digits
    % the less digits of precision, the less unique
    % values of theta that need to be computed.
thetaapprox = roundp(theta,digit);
% thetaapprox(thetaapprox>1.57) = pi/2; % Make theta of approx.pi/2 = pi/2;
[thetacompute,~,indextheta] = unique(thetaapprox);
% approximated scattering angle u
ucompute = cos(thetacompute);
% ucompute(abs(ucompute)<1E-4) = 0; % Make Cosines of Pi/2 = 0;
num = length(ucompute);

Nmax=round(2+alpha+4*alpha.^(1/3));
N=(1:Nmax);
N2NN=(2*N+1)./(N.*(N+1));
[~,aN,bN]=Mie_ab(m,alpha);

% wb=waitbar(0,'Calculating Mie Series...');
multiWaitbar('Calculating Mie Series...',0);
p = NaN(Nmax,num);
t = p;
for j = 1:num
    [~,p(:,j),t(:,j)] = Mie_pt(ucompute(j),Nmax);
%     pin(j,:) = (p(:,j)'.*N2NN);
%     tin(j,:) = (t(:,j)'.*N2NN)';
%     waitbar(j/num,wb);
    multiWaitbar('Calculating Mie Series...',j/num);
end
% close(wb);
multiWaitbar('closeall');
% same as two commented lines above
pin = bsxfun(@times, p', N2NN);
tin = bsxfun(@times, t', N2NN);

S1j = (aN*pin'+bN*tin');
S2j = (aN*tin'+bN*pin');
S1 = reshape(S1j(indextheta),size(thetaapprox));
S2 = reshape(S2j(indextheta),size(thetaapprox));


% x-polarized light, 
% REF: [1] Ye Pu and Hui Meng, "Intrinsic aberrations due to Mie scattering in
% particle holography," J. Opt. Soc. Am. A 20, 1920-1932 (2003) 
% [2] :/ Tsamg. K. A. Kong, Scattering of Electromagnetic waves
% Ex
Ex = spherical_term .* (cos(phi).^2.*u.*S2 +sin(phi).^2.*S1);
% Ey
Ey = spherical_term .* (sin(phi).*cos(phi)).*(S2.*u -S1);
% Ez
Ez = -spherical_term .* cos(phi).*sin(theta).*S2;
% Etot
E(:,:,1) = Ex; E(:,:,2) = Ey; E(:,:,3) = Ez; 

end


function result = Mie_S12(m, x, u)

% Computation of Mie Scattering functions S1 and S2
% for complex refractive index m=m'+im", 
% size parameter x=k0*a, and u=cos(scattering angle),
% where k0=vacuum wave number, a=sphere radius;
% s. p. 111-114, Bohren and Huffman (1983) BEWI:TDD122
% C. Mätzler, May 2002

Nmax=round(2+x+4*x^(1/3));
ab=Mie_ab(m,x);
aN=ab(1,:);
bN=ab(2,:);

pt=Mie_pt(u,Nmax);
pin =pt(1,:);
tin =pt(2,:);

N=(1:Nmax);
N2NN=(2*N+1)./(N.*(N+1));
pin=N2NN.*pin;
tin=N2NN.*tin;
S1=(aN*pin'+bN*tin');
S2=(aN*tin'+bN*pin');
    
result=[S1;S2];

end


function [ab,aN,bN] = Mie_ab(m,alpha)

% Computes a matrix of Mie Coefficients, aN, bN, 
% of orders N=1 to Nmax, for given complex refractive-index
% ratio m=m'+im" and size parameter alpha=k0*a where k0= wave number in ambient 
% medium for spheres of radius a;
% Eq. (4.88) of Bohren and Huffman (1983), BEWI:TDD122
% using the recurrence relation (4.89) for Dn on p. 127 and 
% starting conditions as described in Appendix A.
% C. Mätzler, July 2002

z=m.*alpha;
Nmax=round(2+alpha+4*alpha.^(1/3));
Nmostmax=round(max(Nmax,abs(z))+16);
N=(1:Nmax); nu = (N+0.5); 

sx=sqrt(0.5*pi*alpha);
px=sx.*besselj(nu,alpha);
p1x=[sin(alpha), px(1:Nmax-1)];
chx=-sx.*bessely(nu,alpha);
ch1x=[cos(alpha), chx(1:Nmax-1)];
gsx=px-1i*chx; gs1x=p1x-1i*ch1x;
dNx(Nmostmax)=0+0i;
for j=Nmostmax:-1:2      % Computation of Dn(z) according to (4.89) of B+H (1983)
    dNx(j-1)=j./z-1/(dNx(j)+j./z);
end;
dn=dNx(N);          % Dn(z), N=1 to Nmax
da=dn./m+N./alpha; 
db=m.*dn+N./alpha;

aN=(da.*px-p1x)./(da.*gsx-gs1x);
bN=(db.*px-p1x)./(db.*gsx-gs1x);

ab=[aN; bN];

end


function [pt,p,t] = Mie_pt(u,Nmax)
% pi_n and tau_n, -1 <= u <= 1, N integer from 1 to Nmax 
% angular functions used in Mie Theory
% Bohren and Huffman (1983), p. 94 - 95

p(1)=1; 
t(1)=u;
p(2)=3*u; 
t(2)=3*cos(2*acos(u));
for N=3:Nmax,
    p1=(2*N-1)./(N-1).*p(N-1).*u;
    p2=N./(N-1).*p(N-2);
    p(N)=p1-p2;
    t1=N*u.*p(N);
    t2=(N+1).*p(N-1);
    t(N)=t1-t2;
end;

pt=[p;t];
end


function Y = roundp( X, N )
%roundp: round with precision
%   Rounds the value X to Nth decimal place
%   X: input value
%   N: number of decimal places
%   Ex: roundp(0.004239, 2) = 4.2e-3
%       roundp(42.39, 1) = 40.00

Y = round(X*10^N)/10^N;

end


