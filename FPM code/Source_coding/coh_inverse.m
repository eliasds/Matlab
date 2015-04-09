function [ r, err ] = coh_inverse( I, N_obj, ...
    num_led, Nspace_led, N_NA,...
    tol, maxIter, minIter, monotone )
%COH_INVERSE  considers coherent inverse for LED array micrscope
%   Outputs: 
%   r: reconsturcted high-res image
%   err: errors at each iteration
%   Inputs:
% Measurements data
%   I: intensity measurements by different LEDs
% Reconstruction property
%   N_obj=[Nx_obj,Ny_obj]: size of the reconstructed image
% Source Property
%   num_led=[numx,numy]: # of LEDs in each dimension
%   Nspace_led=[Nx_led,Ny_led]: spacing between neighboring samples 
%   illuminated by neighboring LEDs
% Imaging system property
%   N_NA: low-pass filter diameter set by the NA = bandwidth of a single 
%   measurment in index
% Iteration parameters
%   tol: maximum change of error allowed in two consecutive iterations
%   maxIter: maximum iterations allowed
%   minIter: minimum iterations
%   monotone: if monotone, error has to monotonically dropping 
%   when iters>minIter  
%
%% reconstruction algorithm: asuume coherent imaging system
% ref [1] G. Zheng, R. Horstmeyer, C. Yang, Nat. Phot, 2013
%
% by Lei Tian, lei_tian@berkeley.edu
% last modified 08/19/2013
% 


%Define Fourier operators
F = @(x) ifftshift(fft2(fftshift(x)));
Ft = @(x) ifftshift(ifft2(fftshift(x)));

% size of measurement
[Nmy,Nmx,Nimg] = size(I);

%% set up the lpf cutoff freq determined by NA
m = [1:Nmx]-Nmx/2-1; n = [1:Nmy]-Nmy/2-1;
[mm,nn] = meshgrid(m,n);
% assume a circular pupil function
w_NA = double(sqrt(mm.^2+nn.^2)<N_NA/2);

clear mm nn m n

%% set up the coordinates for each LED
% center positions of each LED
% # of LEDs on each half side
numhx = (num_led(2)-1)/2;
numhy = (num_led(1)-1)/2;

m = [-numhx:numhx]*Nspace_led(2);
n = [-numhy:numhy]*Nspace_led(1);

[Nsx,Nsy] = meshgrid(m,n);
xcen_led = N_obj(2)/2+1+Nsx;
ycen_led = N_obj(1)/2+1+Nsy;

clear Nsx Nsy m n

%% initialization in FT domain
% using the on-axis (brightfield) image since it contains the DC
% information
TMP = F(sqrt(I(:,:,(Nimg+1)/2)));
% the rest of the spectrum is zero since it is not captured in this single
% image
TMP = padarray(TMP,[(N_obj(1)-Nmy)/2,(N_obj(2)-Nmx)/2]);
tmp = Ft(TMP);

% initialization: by assuming zero/constant phase
tmp = abs(tmp);
R = F(tmp);

clear TMP tmp

figure(88); imagesc(abs(Ft(R))); axis image; colormap gray; colorbar;
title('current guess of the amplitude');
figure(89); imagesc(angle(Ft(R))); axis image; colormap gray; colorbar;
title('current guess of the phase');

%% main algorithm starts here
err1 = inf;
err2 = 50;
err = [];
p = 1:N_obj(2); q = 1:N_obj(1);
iter = 0;

% stopping criteria: when relative change in error falls below some value,
% can change this value to speed up the process by using a larger value but
% will trading off the reconstruction accuracy 
% error is defined by the difference b/w the measurement and the estimated
% images in each iteration
while abs(err1-err2)>tol&&iter<maxIter
    err1 = err2;
    err2 = 0;
    for m = 1:Nimg
        %%% from Fourier to Spatial 
        % crop out the corresponding region of spectrum from the
        % current estimate of the object spectrum
        cen = [xcen_led(m),ycen_led(m)];
        
        S = R(cen(2)-Nmy/2:cen(2)+Nmy/2-1,cen(1)-Nmx/2:cen(1)+Nmx/2-1);
        
        % physically acquired spectrum after lpf
        S_m = S.*w_NA;
        
        % estimated complex field
        f_est = Ft(S_m);
        
        % measured intensity
        I_mea = I(:,:,m);
        
        % update scaling factor for amplitude 
        update_scale = sqrt(I_mea)./abs(f_est);
        
        % compute the total difference to determine stopping criterion
        err2 = err2+sqrt(sum((I_mea(:)-abs(f_est(:)).^2).^2));
        
        
        %%% from Spatial to Fourier
        % update in the Frequency domain
        % update the estimate by enforcing spatial domain constraint
                
        % define the spectrum region which will be updated
        [mm,nn] = meshgrid(p-cen(1),q-cen(2));
        w_NA2 = sqrt(mm.^2+nn.^2)<N_NA/2;
        
        % update the field for nth sub-image
        fn_update = update_scale.*f_est;
        % updated the spectrum of the sub-image
        Fn_est = F(fn_update);
        % update the estimation of the object spectrum by put back into
        % the right place
        R(w_NA2) = Fn_est(w_NA>0);
        
%         figure(3); 
%         subplot(121); imagesc(abs(f1)); axis image; colorbar;
%         subplot(122); imagesc(abs(f2)); axis image; colorbar;
                
%         figure(2); imagesc(log(abs(R))); axis image; 
%         title('current guess of the Spectrum')
        %     pause;
        
    end 
    % record the error and can check the convergence later.
    err = [err,err2];
    iter = iter+1;
    
    % display results
    figure(88); imagesc(abs(Ft(R))); axis image; colormap gray; colorbar;
    title(['current guess of the amplitude, iter=',num2str(iter)]);
    figure(89); imagesc(angle(Ft(R))); axis image; colormap jet; colorbar;
    title('current guess of the phase');
    
    if monotone&&iter>minIter
        if err2>err1
            break;
        end
    end


end

r = Ft(R);


end

