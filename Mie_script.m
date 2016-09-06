tic % clear all; %clc;  %path([pwd,filesep,'MieFunctions'],path);
firstfield = 1;
keepfield = false;
loadhist = false;
histnum = 0;
loadhist = true; if loadhist == true;    firstfield = 1;    histnum = Np;    d2 = d;    z_obj2 = z_obj;    x2 = x;    y2 = y;end

%% System parameters (NA needs to be large enough)
N = 2048; % size of hologram
zpad = N+1024; %Pad hologram for FFT
mag = 4; %Magnification
ps = 5.5E-6; % pixel size
Np = 7; % number of particles
maskon = false; % Use a Coded Aperture Mask (true or false)
masktype = 'spiral';
maskfilename = 'mask1024.mat';
lambda = 0.6328E-6; % Wavelength in meters

%% Particle parameters
dpix = ps/mag; % relative pixel size in meters
dmin = 10E-6; % Minimum particle diameter in meters
dmax = 10E-6; % Maximum particle diameter in meters
d1 = 10E-6; % % Designate diameter of the first particle
zmin = -1.5E-3; % Minimum particle z-location in meters
zmax = 1.5E-3; % Maximum particle z-location in meters
z_obj1 = 0.2E-3; % Designate first particle's axial z-position (in meters)
zres = 0.1E-3; % z-resolution in meters: rounds random z-positions to zres resolution steps for simplicity
x1 = 0/dpix; % Designate first particle's lateral x-position (in pixels, centered at (0,0))
y1 = 0/dpix; % Designate first particle's lateral y-position (in pixels, centered at (0,0))

%% Properties of the medium - Refractive index
% 1.33;              % index of refraction of water
% 0.13455+1i*3.9865; % index of refraction of silver @ 633nm
% 1.5+1i*100;        % index of refraction of crude oil
% 1.46;              % index of refraction of cellulose
n1 = 1.33;   % index of refraction of surrounding medium
n2 = 1.5821; % index of refraction of particles
n3 = 1.46;   % index of refraction offirst particle (default: n3 = n2)


%% Filename to save to
fn = ['Mie',num2str(N),'px_',num2str(Np),'part_'];
if maskon == true
    fn = [fn,masktype,'masked_'];
end
fn = [fn,num2str(round(n1*100)),'n1'];
if round(zmin*1E3) == zmin*1E3 && round(zmax*1E3) == zmax*1E3
    fn = [fn,'_z',num2str(round(zmin*1E3)),'to',num2str(round(zmax*1E3)),'mm'];
else
    fn = [fn,'_z',num2str(round(zmin*1E6)),'to',num2str(round(zmax*1E6)),'um'];
end

%% Use above parameters to create particles
%
k = 2*pi/(lambda/n1); % wave number
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
%}

% Use data from a previous dataset
if loadhist == true
    d(1:histnum) = d2(1:histnum);
    z_obj(1:histnum) = z_obj2(1:histnum);
    x(1:histnum) = x2(1:histnum);
    y(1:histnum) = y2(1:histnum);
    if keepfield == false; Field = 0; end
else
    Field = 0;
end

    
%% Check for fundamental Nyquist Sampling Limit
[fx,fy] = meshgrid((-N/2:N/2-1)*(1/N/dpix));
NAbyLambda = (fx.^2+fy.^2<(n1/lambda)^2);

%% Coded Aperture Mask
mask = 1;
maskpadded = 1;
if maskon == true
    if isequal(masktype,'spiral') || isequal(masktype,'file') || isequal(masktype,'var')
            mask = makemask(N, masktype, maskfilename);
            maskpadded = makemask(zpad, masktype, maskfilename);
    else
        mask = makemask(N, masktype);
        maskpadded = makemask(zpad, masktype);
    end
%     mask = ones(N,N);
%     mask(1:end,1:N/2-1) = 0;
% %     mask(1:N/2-1,1:N/2-1) = 0;
%     mask = rot90(mask,0);
end


%Esave = zeros(Hsize,Hsize,length(z));
%% Mie solver
% assuming x-polarized illumination
% generating total field
% Ex_all = zeros(N,N,Np);
multiWaitbar(['Creating E-Fields for ', num2str(1 + Np - firstfield),' Particles'],0);
for p = firstfield:Np
    if abs(z_obj(p)) < 200E-6
        z_obj(p) = 0;
        [xmesh, ymesh] = meshgrid(((-ceil(N/2):ceil(N/2-1))+x(p))*dpix,((-ceil(N/2):ceil(N/2-1))+y(p))*dpix);
        Ex = -1*double(xmesh.^2+ymesh.^2<(d(p)/2)^2);
        Ex2 = Ex;
    else
        [~,Ex] = MieField(n1, n2, d(p), lambda, N, dpix, abs(z_obj(p)), [x(p), y(p)], 4);
        Ex = Ex.*exp(-1i*k*abs(z_obj(p)));
        Ex2 = ifft2(ifftshift(fftshift(fft2(Ex)).*NAbyLambda));
    end
    while sum(isnan(Ex2(:))) > 0
        disp(['Found NaNs in E-Field for Particle ',num2str(p),'. Reattempting']);
        x(p) = x(p) - 1;
        [~,Ex] = MieField(n1, n2, d(p), lambda, N, dpix, abs(z_obj(p)), [x(p), y(p)], 4);
        Ex = Ex.*exp(-1i*k*abs(z_obj(p)));
        Ex2 = ifft2(ifftshift(fftshift(fft2(Ex)).*NAbyLambda));
    end
    if     z_obj(p) <  0
        Ex2 = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad,'cpu');
        Ex2 = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad,'mask',maskpadded,'cpu');
    elseif z_obj(p) == 0 && maskon == true
        Ex2 = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad,'mask',maskpadded,'cpu');
    elseif z_obj(p) >  0 && maskon == true
        Ex2 = propagate(Ex2,lambda/n1,-z_obj(p),ps/mag,'zpad',zpad,'cpu');
        Ex2 = propagate(Ex2,lambda/n1,z_obj(p),ps/mag,'zpad',zpad,'mask',maskpadded,'cpu');
    end
    Field = Field + Ex2; % record total field for comparison.
%     Ex_all(:,:,p) = Ex2;
    multiWaitbar(['Creating E-Fields for ', num2str(1 + Np - firstfield),' Particles'],(1 + p - firstfield)/(1 + Np - firstfield));
end
multiWaitbar('closeall');

% Generating hologram
Holo = 1+2*real(Field)+abs(Field).^2;
Holo_fft = fftshift(fft2(Holo));
HoloMasked = ifft2(ifftshift(Holo_fft.*mask));

theta = atan(dpix*N/2/max(abs(z_obj)));
NA = n1*sin(theta); % Numerical Aperture
xy_res = (lambda/n1)/NA; % Lateral Resolution
DOF = (lambda/n1)/NA^2; % Depth of Focus

% set(0,'DefaultFigureWindowStyle','docked') %Dock all figures
figure; imagesc(Holo,[0 max(Holo(:))]); colormap gray; colorbar; axis image; axis ij;
% if maskon == true
%     figure; imagesc(mask); colormap gray; colorbar; axis image; axis ij;
% end

save(fn, 'Holo', 'Field', 'z_obj', 'x', 'y', 'N', 'Np', 'd', 'dpix', 'lambda', 'k', 'n1', 'n2', 'n3', 'zmin', 'zmax', 'mag', 'ps', 'zpad', 'mask', 'maskpadded', 'maskon', 'masktype', 'theta', 'NA', 'xy_res', 'DOF');
toc
