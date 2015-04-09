% include spatial partial coherence effects

% By Lei Tian, lei_tian@berkeley.edu
% last modified 8/16/2013

% assume the intensity distribution of each individual LED is known and
% they have the same angular intensity distribution. In practice,
% off-center LEDs will have different angular intensity distribution as
% compared to near-center LEDs. Will consider that in the next version.

% last modified 8/18/2013

% use functions for inversion and comparison b/w coherent inversion and pc
% inversion
% last modified 8/19/2013

% added monotone option in iterations
% last modified 8/20/2013

% try random source coding
% last modified by Lei Tian, 10/09/2013
% put in real experimental parameters
% 10/10/2013

% inverse problem use alternating projection
% 2/28/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all; clc;

%addpath(['.\Source_coding']);

% Define Fourier operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));

% Define RMSE function operator
RMSE = @(x,x0) sqrt(sum(abs(x(:)-x0(:)).^2)/sum(x0(:).^2));


%% load in test image
% % assume pure amplitue object
tmp = double(imread('1.jpg'));
tmp = tmp(:,:,2);
% tmp2 = double(imread('1.tiff'));
ampl = tmp/max(tmp(:))*0.1;
% ampl = 1;
% ph = tmp2(1:1000,1:1000)/max(tmp2(:));
% ph = tmp/max(tmp(:))*pi/2;
tmp = double(imread('2.jpg'));
tmp = tmp(:,:,2);
ph = tmp/max(tmp(:))*pi/5;
% obj = obj.*exp(1i*pi/10*ph);
% obj = 1.*exp(1i*pi/2*obj);
obj = ampl.*exp(1i*ph);

clear ampl ph tmp

% wavelength of illumination, assume monochromatic
lambda = 0.632;

%% imaging by the microscope
% % filtered by a 10X objective lens (0.25 NA)
% and then the field's intensity is recorded by an image sensor
% with 5.5mum pixel size
NA = 0.25;
% maximum spatial frequency set by NA
um_m = NA/lambda;
% system resolution based on the NA
dx0 = 1/um_m/2;

% magnification of the system
mag = 10;

% effective image pixel size on the object plane
dpix_m = 6.5/mag; %5.3um pixel size on the sensor plane
% # of pixels at the output image
Np = 200;
% FoV in the object space
FoV = Np*dpix_m;
% sampling size at Fourier plane set by the image size (FoV)
% sampling size at Fourier plane is always = 1/FoV
du = 1/FoV;

% low-pass filter diameter set by the NA = bandwidth of a single measurment
% in index
% N_NA = round(2*um_m/du_m);
% generate cutoff window by NA
m = 1:Np;
[mm,nn] = meshgrid(m-Np/2-1);
ridx = sqrt(mm.^2+nn.^2);
um_idx = um_m/du; 
% assume a circular pupil function, lpf due to finite NA
w_NA = double(ridx<um_idx);

phC = ones(Np);
%phC(ridx<0.8*um_idx&ridx>0.7*um_idx) = 0.5;
% aberration modeled by a phase function
aberration = ones(Np);
aberration = exp(pi/2*1i*(exp(-(mm-20).^2/50^2-(nn+40).^2/150^2))-...
    pi/8*1i*(exp(-(mm+40).^2/100^2-(nn-80).^2/80^2))+...
    pi/3*1i*(exp(-(mm).^2/60^2-(nn-10).^2/30^2)));


%aberration = ones(N_m);
pupil = w_NA.*phC.*aberration;

%clear m mm nn

%% LED array geometries and derived quantities
% spacing between neighboring LEDs
ds_led = 4e3; %4mm
% confocal length of condenser
fc = 60e3;

% diameter of # of LEDs within condenser aperture
dia = 20;
% LED coordinates
xled = [0:31]-17;
[xx,yy] = meshgrid(xled,xled);
rr = sqrt(xx.^2+yy.^2);
illumination_na = sin(atan(rr*ds_led / fc));

condenserCoord = rr<dia/2;
% total number of LEDs within the condenser area
Nled=sum(condenserCoord(:));
% index of LEDs within the condenser region
condenseridx = find(condenserCoord);
% corresponding angles for each LEDs
thetax = atan(xx*ds_led/fc); thetay = atan(yy*ds_led/fc);
% corresponding spatial freq for each LEDs
uled = sin(thetax)/lambda; vled = sin(thetay)/lambda;
% spatial freq index for each plane wave relative to the center
idx_u = round(uled/du);
idx_v = round(vled/du);

% maxium spatial frequency achievable based on the maximum illumination
% angle from the LED array and NA of the objective
um_p = sin(atan(dia/2*ds_led/fc))/lambda+um_m;
% resolution achieved after freq post-processing
dx0_p = 1/um_p/2;

disp(['super-resolution rate is ',num2str(um_p/um_m)]);

% assume the max spatial freq of the original object
% um_obj>um_p
% assume the # of pixels of the original object
N_obj = round(um_p/du/2)*2*4;
% max spatial freq of the original object
um_obj = du*N_obj/2;

% sampling size of the object (=pixel size of the test image)
dx_obj = 1/um_obj/2;
% size of object
N0 = length(obj);
% original object (zero padding if the test image is too small)
if N_obj>N0
    obj = padarray(obj,[(N_obj-N0)/2,(N_obj-N0)/2],mean2(obj));
else
    obj = obj((N0-N_obj)/2:(N0+N_obj)/2-1,(N0-N_obj)/2:(N0+N_obj)/2-1);
end
% spectrum of the object
OBJ = F(obj);

%% illumination coding Expt
% Define the intensity distribution of the LED
% this assumes each LED has the same angular intensity distribution, which
% is not entirely true. A better way is to define a LED intensity
% distribution, but for off-center and near-center LEDs, different cone of
% angles are entered into the imaging NA.
% %% design parameter: # of images (= # of off-center LEDs at each side)
% % note that this number (Nr_img) controls the amount of data overlapping in
% % the Fourier domain. As in Zhang's paper, a good amount of overlapping
% % (65% for their case) is necessary in order to ensure convergence of the
% % reconstruction algorithm. Decreasing Nr_img reduces the amount of
% % overlapping.
% % spacing between neighboring samples from different LED illuminations
% Nspace = ceil((Nmax_u-N_NA/2)/Nr_img);
% % check: overlapping rate = spacing b/w neighing sample / bandwidth of a
% % single measurement
% disp(['overlapping rate is ', num2str(Nspace/N_NA)]);

% # of LED lit for each images
numlit = 2;
% total # of images to be taken
Nimg = round(Nled/numlit*1.2);
% 
%ledidx = randsample(Nled,numlit*Nimg);
ledidx = round(rand(numlit,Nimg)*Nled);
%ledidx = randsample(Nled,numlit*Nimg);
ledidx(ledidx<1) = 1;
ledidx(ledidx>Nled) = Nled;
ledidx = reshape(ledidx,numlit,Nimg);
% index of LEDs are lit for each pattern
lit = condenseridx(ledidx);
% % # of trials given the expt setting above
% trial = 10;
lit = reshape(lit,numlit,Nimg);

%%
% for ii = 1:trial
% simulating intensity measurements
I = zeros(Np,Np,Nimg);
Nsx_lit = zeros(numlit,Nimg);
Nsy_lit = zeros(numlit,Nimg);
for m = 1:Nimg
    % should make sure it always covers all the leds
    % index of LEDs are lit for each pattern
    %lit = condenseridx(ceil(rand(numlit,1)*Nled));
    % corresponding index of spatial freq for the LEDs are lit
    lit0 = lit(:,m);
    Nsx_lit(:,m) = idx_u(lit0);
    Nsy_lit(:,m) = idx_v(lit0);
    
    % display the LED lit pattern
    % LEDarray = zeros(32,32);
    % LEDarray(lit) = 1;
    % figure; imagesc(LEDarray);
    I(:,:,m) = illumination_pattern_intensity( OBJ, ...
        [Nsx_lit(:,m),Nsy_lit(:,m)],pupil, [Np, Np]);
    
    %     figure(idx); imagesc(I(:,:,idx)); axis image;colormap gray;colorbar;
    %         pause(.2);
end
% % compensate for numerical scaling
I = I*N_obj^4/Np^4;
% center of led offset w.r.t to the center of the image center
Ns(:,:,1) = Nsy_lit;
Ns(:,:,2) = Nsx_lit;

%% reconstruction algorithm: partial coherence effect in both spatial and
% Fourier domain
% spatial updating method:
% ref [1] C. Rydberg, J. Bengtsson, Opt. Express, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the idea of the inverse algorithm is that each point on LED is a coherent
% mode. The total intensity is the sum of the intensities due to all the
% modes.
% although we do not know the actual intensity for each modes, as show in
% [1], an update rule for amplitude can be found by properly scale the
% estimated amplitude for each modes. Again, the phase part is left
% unchanged.
opts.tol = 1;
opts.maxIter = 100;
opts.minIter = 3;
opts.monotone = 0;
opts.update_mode = 1;
% 'full', display every subroutin, 
% 'iter', display only results from outer loop
% 0, no display
opts.display = 'iters'; 
opts.saveIterResult = 1;
opts.out_dir = ['.\tmp2'];
mkdir(opts.out_dir);
[~,ii] = find(ledidx == (Nled+1)/2);
opts.O0 = Ft(sqrt(I(:,:,ii(1))));
opts.O0 = padarray(opts.O0,[(N_obj-Np)/2,(N_obj-Np)/2]);
opts.P0 = w_NA;
opts.alpha = 1;
opts.beta = 1;
opts.mode = 'fourier';

tic;



% partial coherent inversion
[O,P,err_pc] = AlterMinSeq(I,[N_obj,N_obj],Ns,opts);
t(2) = toc;

%%
f1 = figure(88);
subplot(221); imagesc(abs(o)); axis image; colormap gray; colorbar;
title('ampl(o)');
subplot(222); imagesc(angle(o)); axis image; colormap gray; colorbar;
title('phase(o)');
subplot(223); imagesc(abs(P)); axis image; colormap gray; colorbar;
title('ampl(P)');
subplot(224); imagesc(angle(P)); axis image; colormap gray; colorbar;
title('phase(P)');

% figure(99); imagesc(obj); axis image; colormap gray; colorbar;
% title('original object')
figure(100); imagesc(abs(o-obj)); axis image; colorbar;
title('PC reconstruction error map')

figure(70); semilogy(err_pc); xlabel('# of iterations');
ylabel('error')
title('PC convergence curve')

disp(['RMSE is ',num2str(RMSE(O,obj))]);

% %% saving results
% fn = ['RandLit-',num2str(numlit),'-',num2str(Nimg)];
% save(fn, 'Nsx_lit','Nsy_lit','o', 'P','err_pc');
% 
% % end



%% reconstruction algorithm: partial coherence effect in both spatial and
% Fourier domain
% spatial updating method:
% ref [1] C. Rydberg, J. Bengtsson, Opt. Express, 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the idea of the inverse algorithm is that each point on LED is a coherent
% mode. The total intensity is the sum of the intensities due to all the
% modes.
% although we do not know the actual intensity for each modes, as show in
% [1], an update rule for amplitude can be found by properly scale the
% estimated amplitude for each modes. Again, the phase part is left
% unchanged.
opts.tol = 1;
opts.minIter = 3; %
opts.maxIter = 100;
opts.monotone = 0;
opts.update_mode = 1;
opts.display = 1;
opts.saveIterResult = 1;
opts.out_dir = ['\tmp_NP']; mkdir(opts.out_dir);
[~,ii] = find(ledidx == (Nled+1)/2);
opts.R0 = Ft(sqrt(I(:,:,ii(1))));
opts.R0 = padarray(opts.R0,[(N_obj-Np)/2,(N_obj-Np)/2]);

tic;

% partial coherent inversion
[r_pc,err_pc] = Illumination_pattern_inverse( I, ...
    [du,du], um_m, [N_obj,N_obj], Ns, opts );
t(2) = toc;

% display the results
figure(88); imagesc(abs(r_pc)); axis image; colormap gray; colorbar;
title('PC reconstructed amplitude')
figure(89); imagesc(angle(r_pc)); axis image; colorbar;
title('PC reconstructed phase')

% figure(99); imagesc(obj); axis image; colormap gray; colorbar;
% title('original object')
figure(100); imagesc(abs(r_pc)-obj); axis image; colorbar;
title('PC reconstruction error map')

figure(70); semilogy(err_pc); xlabel('# of iterations');
ylabel('error')
title('PC convergence curve')

disp(['RMSE is ',num2str(RMSE(r_pc,obj))]);


