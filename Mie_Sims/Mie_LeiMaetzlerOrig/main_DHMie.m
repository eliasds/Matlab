clc; 
path([pwd,filesep,'MieFunctions'],path);

%% system parameters: NA needs to be large enough
% size of hologram
N = 256;
% pixel size
dpix = 2e-3; % in mm
% number of particles
Np = 10;

% random particle size between dmin and dmax
dmin = 20;
dmax = 70;
d = (rand([1,Np])*(dmax-dmin)+dmin)*1e-3; % diameter range from 20 to 50 um


%% parameters of the particles
% medium
n1 = 1.33;   % index of refraction of water
% index of the particle
n2 = 1;

lambda = 0.6328e-3; % in mm
k = 2*pi/lambda*n1;

% crude oil
% n2 = 1.5+100i; % index of refraction of the sphere
% air bubble, oil drop, particle

% delta_x = lambda/NA % lateral resolution
% DOF = lambda/NA^2 % depth of focus

%n2 = [1 1.5 1.45+100i]

% particle z locations randomly between zmin and zmax
zmin = 3;
zmax = 9;
zres = 0.25;
% will only allow z take .25 resolution steps for simplicity.
z_obj = round((rand([1,Np])*(zmax-zmin)+zmin)/zres)*zres; %distance range from 5 to 15

% lateral random locations
x = round(rand([1,Np])*N/4*3-N/8*3);
y = round(rand([1,Np])*N/4*3-N/8*3);

%Esave = zeros(Hsize,Hsize,length(z));
%% Mie solver
% assuming x-polarized illumination
% generating total field
Etot = 0;
for p = 1:Np
    E = Mie_x_radiation2(n1, n2, d(p), lambda, N, dpix, z_obj(p), [ x(p), y(p)], 6);
%     t = [1 0 0; 0 1 0; 1];
%     t_translate = maketform('affine',t);
%     Etmp = imtransform(E(:,:,1), t_translate,...
%         'XData',[1 N],'YData',[1 N]);
    
    Etot = Etot+E(:,:,1).*exp(-1i*k*z_obj(p));
    
end

% generating hologram
Holo = 1+2*real(Etot)+abs(Etot).^2;
% record totol field for comparison.
Field = Etot;

figure; imagesc(Holo); axis image;

fn = ['MieBubble',num2str(N),'_',num2str(Np)];
save(fn, 'Holo', 'Field', 'z_obj', 'x', 'y', 'd', 'dpix', 'lambda', 'n1', 'n2');