tic % clear all; %clc;  %path([pwd,filesep,'MieFunctions'],path);
firstfield = 1;
keepfield = false;
loadhist = false;
histnum = 0;
loadhist = false; if loadhist == true;    firstfield = 1;    histnum = Np;    d2 = d;    z_obj2 = z_obj;    x2 = x;    y2 = y;end

%% System parameters (NA needs to be large enough)
N = 2048; % size of hologram
zpad = N; %Pad hologram for FFT
mag = 500/75; %Magnification
ps = 5.5E-6; % pixel size
maskon = false; % Use a Coded Aperture Mask (true or false)
masktype = 'spiral';
maskfilename = 'mask2048.mat';
lambda = 0.6328E-6; % Wavelength in meters

%% Particle parameters
dpix = ps/mag; % relative pixel size in meters
% Designate diameter of all particle sizes
d = [100e-6, repmat(10e-6,[1,6])];
% Designate axial (z) particle locations (in meters)
z_obj =   [5e-3,   7e-3,   5e-3,   4e-3,   3e-3,   5e-3,   6e-3]-0e-3;
% Designate lateral (x,y) particle locations (in pixels, centered at (0,0))
x = round([0,     -100e-6, 0,      75e-6, -200e-6, 0,      150e-6]/dpix);
y = round([0,      100e-6, 100e-6, 75e-6,  200e-6, 200e-6, 150e-6]/dpix);

%% Properties of the medium - Refractive index
n1 = 1.33;   % index of refraction of water
% n2 = 0.13455+1i*3.9865; %indez of refraction of silver @ 633nm
% n2 = 1.5+1i*100; % index of refraction of crude oil
n2 = 1.5821; % index of refraction of polystyrene (particles)
n3 = 1.46; %index of refraction of cellulose (first particle)

%% Use above parameters to create more parameters
%
k = 2*pi/(lambda/n1); % wave number
zmin = min(z_obj);
zmax = max(z_obj);
if numel(z_obj) == numel(x) && numel(z_obj) == numel(y) && numel(z_obj) == numel(d)
    Np = numel(z_obj); % number of particles
else
    error('Number of designated particles in x, y, z, and "d", do not match')
end

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
