tic
clear all
%clc; 
%path([pwd,filesep,'MieFunctions'],path);

%% System parameters (NA needs to be large enough)
N = 512; % size of hologram
zpad = 1024; %Pad hologram for FFT
mag=4; %Magnification
ps = 5E-6; % pixel size
Np = 8; % number of particles
maskon = false; % Use a Coded Aperture Mask (true or false)
masktype = 'knife';
lambda = 0.6328E-6; % Wavelength in meters

%% Particle parameters
dmin = 10E-6; % Minimum particle diameter in meters
dmax = 10E-6; % Maximum particle diameter in meters
d1 = 10E-6; % Make the first particle a specific size
zmin = -2.5E-3; % Minimum particle z-location in meters
zmax = 2.5E-3; % Maximum particle z-location in meters
z_obj1 = 2.5E-3; % Put the first particle in a specific z-position
zres = 0.25E-3; % z-resolution in meters: rounds random z-positions to zres resolution steps for simplicity.
x1 = 0; % Put the first particle in a specific x-position
y1 = 0; % Put the first particle in a specific x-position

%% Properties of the medium
n1 = 1.33;   % index of refraction of water
% index of the particle
%n2 = 0.13455+1i*3.9865; %index of refraction of silver @ 633nm
n2 = 1.5821; % index of refraction of polystyrene
n3 = 1.46; %index of refraction of cellulose
% crude oil
% n2 = 1.5+1i*100; % index of refraction of the sphere/air bubble/particle


%% Filename to save to
fn = ['Mie',num2str(N),'px_',num2str(Np),'part_',num2str(round(n1*100)),'n1_',num2str(round(n2*100)),'n2'];
if maskon == true
    fn = ['Mie',num2str(N),'px_',num2str(Np),'part_',num2str(round(n1*100)),'masked_n1_',num2str(round(n2*100)),'n2'];
end

%% Use above parameters to create particles
dpix = ps/mag; % relative pixel size in meters
k = 2*pi/lambda*n1; % wave number
% Make random particle sizes between dmin and dmax in meters
d = (rand([1,Np])*(dmax-dmin)+dmin);
% Make the first particle a specific size
d(1)=d1;
% Make random particle z-locations between zmin and zmax (in meters)
z_obj = round((rand([1,Np])*(zmax-zmin)+zmin)/zres)*zres;
% Put the first particle in a specific z-position 
z_obj(1) = z_obj1;

% Create random particle lateral (x-y) locations (in pixels)
x = round(rand([1,Np])*N/4*3-N/8*3);
y = round(rand([1,Np])*N/4*3-N/8*3);
% Put the first particle in a specific x-y-position 
x(1) = x1;
y(1) = y1;
% x(1) = -round(N*21/128)-10;
% y(1) = -round(N*21/128)-40;
% x(2) = round(N*21/128)-20;
% y(2) = round(N*21/128)+30;
% x(3) = -round(N*21/128)-40;
% y(3) = -40;


%% Coded Aperture Mask
mask = 1;
maskpadded = 1;
if maskon == true
    mask = makemask(N, masktype);
    maskpadded = makemask(zpad, masktype);
%     mask = ones(N,N);
%     mask(1:end,1:N/2-1) = 0;
% %     mask(1:N/2-1,1:N/2-1) = 0;
%     mask = rot90(mask,0);
end


%Esave = zeros(Hsize,Hsize,length(z));
%% Mie solver
% assuming x-polarized illumination
% generating total field
Field = 0;
% Ex_all = zeros(N,N,Np);
% z_obj=abs(z_obj);
for p = 1:Np
    E = MieField(n1, n2, d(p), lambda, N, dpix, abs(z_obj(p)), [x(p), y(p)], 4);
    Ex = E(:,:,1).*exp(-1i*k*abs(z_obj(p)));
    if z_obj(p) < 0
        Ex2 = propagate(Ex,lambda/n1,z_obj(p),ps/mag,'zpad',zpad);
        if maskon==true
            Ex = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad,'mask',maskpadded);
        else
            Ex = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad);
        end
    end
    
%     t = [1 0 0; 0 1 0; 1];
%     t_translate = maketform('affine',t);
%     Etmp = imtransform(E(:,:,1), t_translate,...
%         'XData',[1 N],'YData',[1 N]);
    
    % record total field for comparison.
    Field = Field + Ex;
%     Ex_all(:,:,p) = Ex;
    
end

% Generating hologram
Holo = 1+2*real(Field)+abs(Field).^2;
Holo_fft = fftshift(fft2(Holo));
HoloMasked = ifft2(ifftshift(Holo_fft.*mask));

theta = atan(ps*N/2/max(z_obj));
NA = n1*sin(theta);
xy_res = lambda/NA; % lateral resolution
DOF = lambda/NA^2; % depth of focus

% set(0,'DefaultFigureWindowStyle','docked') %Dock all figures
figure; imagesc(Holo,[0 max(Holo(:))]); colormap gray; colorbar; axis image; axis ij;
% if maskon == true
%     figure; imagesc(mask); colormap gray; colorbar; axis image; axis ij;
% end

save(fn, 'Holo', 'Field', 'z_obj', 'x', 'y', 'N', 'Np', 'd', 'dpix', 'lambda', 'k', 'n1', 'n2', 'n3', 'zmin', 'zmax', 'mag', 'ps', 'mask', 'maskpadded', 'maskon', 'theta', 'NA', 'xy_res', 'DOF');
toc