%clc; 
%path([pwd,filesep,'MieFunctions'],path);

%% system parameters: NA needs to be large enough
% size of hologram
N = 512;
%Magnification
mag=4;
% pixel size
ps = 5.5E-6;
dpix = ps/mag; % in meters
% number of particles
Np = 1;
% Use a Coded Aperture Mask
maskon=true;

% random particle size between dmin and dmax in meters
dmin = 10E-6;
dmax = 10E-6;
d = (rand([1,Np])*(dmax-dmin)+dmin); % diameter range from dmin to dmax
% Make the first particle a specific size
d(1)=10E-6;

%% parameters of the particles
% medium
n1 = 1.33;   % index of refraction of water
% index of the particle
%n2 = 0.13455+j*3.9865; %silver @ 633nm
n2 = 1.5821; %polystyrene
n3 = 1.46; %cellulose

%% Coded Aperture Mask
mask=ones(N,N);
mask(1:end,1:N/2-1)=0;
% mask=flipud(mask);
% mask=fliplr(mask);
maskpadded = imresize(mask,'scale',2,'method','nearest');

lambda = 0.6328E-6; % in meters
k = 2*pi/lambda*n1;

% crude oil
% n2 = 1.5+100i; % index of refraction of the sphere
% air bubble, oil drop, particle

% delta_x = lambda/NA % lateral resolution
% DOF = lambda/NA^2 % depth of focus

%%
% particle z locations randomly between zmin and zmax (in meters)
zmin = -2E-3;
zmax = 2E-3;
zres = 0.25E-3; % resolution in meters
% will only allow z take .25 resolution steps for simplicity.
z_obj = round((rand([1,Np])*(zmax-zmin)+zmin)/zres)*zres; %distance range from 5 to 15
% Put the first particle in a specific z-position 
z_obj(1) = 6E-3; %in meters

% lateral random locations
x = round(rand([1,Np])*N/4*3-N/8*3);
y = round(rand([1,Np])*N/4*3-N/8*3);

% Put the first particle in a specific x-y-position 
x(1)=0;
y(1)=0;

%Esave = zeros(Hsize,Hsize,length(z));
%% Mie solver
% assuming x-polarized illumination
% generating total field
Etot = 0;
% E = Mie_x_radiation2(n1, n2, d(1), lambda, N, dpix, z_obj(1), [ x(1), y(1)], 4);
% Etot = Etot+E(:,:,1).*exp(-1i*k*z_obj(1));

for p = 1:Np
    E = Mie_x_radiation3(n1, n2, d(p), lambda, N, dpix, z_obj(p), [ x(p), y(p)], 4);
    if maskon==true
        Ex = E(:,:,1);
        Ex2 = propagate(Ex,lambda/n1,-z_obj(p),ps/mag,'zpad',N*2);
        Ex = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',N*2,'mask',mask);
    end
    
%     t = [1 0 0; 0 1 0; 1];
%     t_translate = maketform('affine',t);
%     Etmp = imtransform(E(:,:,1), t_translate,...
%         'XData',[1 N],'YData',[1 N]);
    
    Etot = Etot+Ex.*exp(-1i*k*z_obj(p));
    
end

% generating hologram
Holo = 1+2*real(Etot)+abs(Etot).^2;
% record total field for comparison.
Field = Etot;

% set(0,'DefaultFigureWindowStyle','docked') %Dock all figures
figure; imagesc(Holo,[0 max(Holo(:))]); axis image; colormap gray; colorbar; axis ij;

fn = ['Mie',num2str(N),'px_',num2str(Np),'part_',num2str(round(n1*100)),'n1_',num2str(round(n2*100)),'n2'];
save(fn, 'Holo', 'Field', 'z_obj', 'x', 'y', 'd', 'dpix', 'lambda', 'n1', 'n2', 'n3', 'zmin', 'zmax', 'mag', 'ps');
