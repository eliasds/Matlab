function [ r, err ] = pc_inverse2( I, N_obj, ...
    num_led, N_led, Nspace_led, I_led, N_NA,...
    update_mode, tol, maxIter, minIter, monotone )
%PC_INVERSE considers partial coherence inverse for LED array micrscope
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
%   N_led=[Nx_led,Ny_led]: # of pixel spread of LED in spatial freq domain
%   I_led: intensity distribution of LED
%   Nspace_led=[Nx_led,Ny_led]: spacing between neighboring samples
%   illuminated by neighboring LEDs
% Imaging system property
%   N_NA: low-pass filter diameter set by the NA = bandwidth of a single
%   measurment in index
% Iteration parameters
%   update_mode: different update method to treat sub-images created by
%   different pts on the LED
%   update_mode = 1: weighted average; = 0: direct replacement sequentially
%   tol: maximum change of error allowed in two consecutive iterations
%   maxIter: maximum iterations allowed
%   minIter: minimum iterations
%   monotone: if monotone, error has to monotonically dropping 
%   when iters>minIter  
%
%
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
%
% by Lei Tian, lei_tian@berkeley.edu
% within each LED, different sub-images' spectrum are replaced sequentially
% last modified 08/19/2013
%
% within each LED, weighted average of the spectrum overlapping patches of
% all the sub-images
% last modified 08/19/2013

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

% relative LED shift w.r.t. its center
[x_led,y_led] = meshgrid(-(N_led(2)-1)/2:(N_led(2)-1)/2,...
    -(N_led(1)-1)/2:(N_led(1)-1)/2);% coordinates of points on led

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
        % estimated intensity. Note again the amplitude distribution of the
        % LED is assumed to be known a prior
        
        %%% from Fourier to Spatial
        % estimate the intensity for each mode (point on the LED)
        % initialization
        I_est = 0; % estimated intensity
        fn_est = zeros(Nmy,Nmx,N_led(1)*N_led(2)); % estimated field for each mode
        for n = 1:N_led(1)*N_led(2)
            % center for each sub-image created by each point on the LED
            cen = [xcen_led(m),ycen_led(m)]+[x_led(n),y_led(n)];
            % crop out the corresponding region of spectrum from the
            % current estimate of the object spectrum
            S = R(cen(2)-Nmy/2:cen(2)+Nmy/2-1,cen(1)-Nmx/2:cen(1)+Nmx/2-1);
            
            % physically acquired spectrum after lpf
            S_m = S.*w_NA;
            
            % estimated complex field for each mode
            % scaling factor due to FFT
            % fn_est(:,:,n) = Ft(S_m)/N_obj(1)/N_obj(2)*Nmx*Nmy;
            fn_est(:,:,n) = Ft(S_m);
            
            % intensity of each sub-images
            I_est = I_est+I_led(n)*abs(fn_est(:,:,n)).^2;
        end
        
        % measured intensity
        I_mea = I(:,:,m);
        
        % update scaling factor for amplitude of each mode, notice the
        % similarity b/w GS algorithm.
        update_scale = sqrt(I_mea./I_est);
        
        % compute the total difference to determine stopping criterion
        err2 = err2+sqrt(sum((I_mea(:)-I_est(:)).^2));
        
        %         figure(3);
        %         subplot(121); imagesc(abs(f1)); axis image; colorbar;
        %         subplot(122); imagesc(abs(f2)); axis image; colorbar;
        
        %%% from Spatial to Fourier
        % update in the Frequency domain, do it mode-by-mode
       
        if update_mode % weighted average
            Rtmp = zeros(N_obj);
            wtmp = zeros(N_obj);
            for n = 1:N_led(1)*N_led(2)
                % center for each sub-image created by each point on the LED
                cen = [xcen_led(m),ycen_led(m)]+[x_led(n),y_led(n)];
                
                % define the spectrum region which will be updated
                [mm,nn] = meshgrid(p-cen(1),q-cen(2));
                w_NA2 = sqrt(mm.^2+nn.^2)<N_NA/2;
                
                wt = I_led(n)/sum(I_led(:));
                wtmp = double(w_NA2)*wt+wtmp;
                
                % update the field for nth sub-image
                fn_update = update_scale.*fn_est(:,:,n);
                % updated the spectrum of the sub-image
                Fn_est = F(fn_update);
                % update the estimation of the object spectrum by put back into
                % the right place
                
                tmp = zeros(N_obj);
                tmp(w_NA2) = Fn_est(w_NA>0)*wt;
                Rtmp = Rtmp+tmp;
                
                %             figure(2); imagesc(log(abs(R))); axis image;
                %             title('current guess of the Spectrum')
            end
            idx = find(wtmp);
            R(idx) = Rtmp(idx)./wtmp(idx);
        else
            % replace each sub-patch sequentially w/o considering different
            % weights due to non-uniform intensity of the LED
            for n = 1:N_led(1)*N_led(2)
                % center for each sub-image created by each point on the LED
                cen = [xcen_led(m),ycen_led(m)]+[x_led(n),y_led(n)];
                
                % define the spectrum region which will be updated
                [mm,nn] = meshgrid(l-cen(1),l-cen(2));
                w_NA2 = sqrt(mm.^2+nn.^2)<N_NA/2;
                
                % update the field for nth sub-image
                fn_update = update_scale.*fn_est(:,:,n);
                % updated the spectrum of the sub-image
                Fn_est = F(fn_update);
                % update the estimation of the object spectrum by put back 
                % into the right place
                R(w_NA2) = Fn_est(w_NA>0);
                
                %             figure(2); imagesc(log(abs(R))); axis image;
                %             title('current guess of the Spectrum')
                
            end
            
        end
        
        
%         figure(2); imagesc(log(abs(R))); axis image;
%         title('current guess of the Spectrum')
        
        %         % display results
        %         figure(88); imagesc(abs(Ft(R))); axis image; colormap gray; colorbar;
        %         title('current guess of the amplitude');
        %         figure(89); imagesc(angle(Ft(R))); axis image; colormap gray; colorbar;
        %         title('current guess of the phase');
        
        
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

