function [ r, err ] = Illumination_pattern_inverse( I, du, um, N_obj, Ns, opts)
%Illumination_pattern_inverse considers partial coherence inverse for LED
%array micrscope
%   Outputs:
%   r: reconsturcted high-res image
%   err: errors at each iteration
%
%   Inputs:
% Measurements data
%   I: intensity measurements by different LEDs
%   du: sampling pixel size in spatial freq domain
%   um: Max spatial freq of I set by NA
% Reconstruction parameters
%   N_obj = [Ny_obj,Nx_obj]: size of the reconstructed image
%
%
% Illumination coding parameters
%   Ns = [Nsy,Nsx]: centers of corresponding lpf regions for
%   the illumination pattern

% Iteration parameters: opts
%   update_mode: different update method to treat sub-images created by
%   different pts on the LED
%   update_mode = 1 (default): weighted average; 
%               = 0: direct replacement sequentially
%   tol: maximum change of error allowed in two consecutive iterations
%   maxIter: maximum iterations allowed
%   minIter: minimum iterations
%   monotone (1, default): if monotone, error has to monotonically dropping
%   when iters>minIter
%   display: display results (0: no (default) 1: yes)
%   saveIterResult: save results at each step as images (0: no (default) 1: yes)
%   R0: initial guess of R
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
col = @(x) x(:)';

% size of measurement
[Nmy,Nmx,Nimg] = size(I);
N = [Nmy,Nmx];
% # of LEDs lit up in each pattern
[numlit,~,~] = size(Ns);
cen0 = N_obj/2+1;


% options for the method
if nargin<6
    % default values
    opts.tol = 1;
    opts.maxIter = 50;
    opts.minIter = 3;
    opts.monotone = 1;
    opts.update_mode = 1;
    opts.display = 0;
    opts.saveIterResult = 0;
    opts.out_dir = [];
    %optTol - Termination tolerance on the first-order optimality (1e-5)
    %   progTol - Termination tolerance on progress in terms of
    % function/parameter changes (1e-9)
    opts.R0 = Ft(sqrt(I(:,:,1)))/numlit;
    opts.R0 = padarray(opts.R0,(N_obj-N)/2);
else
    if ~isfield(opts,'tol')
        opts.tol = 1;
    end
    if ~isfield(opts,'maxIter')
        opts.maxIter = 50;
    end
    if ~isfield(opts,'minIter')
        opts.minIter = 3;
    end
    if ~isfield(opts,'monotone')
        opts.monotone = 1;
    end
    if ~isfield(opts,'update_mode')
        opts.update_mode = 1;
    end
    if ~isfield(opts,'display')
        opts.display = 0;
    end
    if ~isfield(opts,'saveIterResult')
        opts.saveIterResult = 0;
    end
    if ~isfield(opts,'out_dir')
        opts.out_dir = ['IterResults'];
        if opts.saveIterResult
            mkdir(opts.out_dir);
        end
    end
    if ~isfield(opts,'R0')
        opts.R0 = F(sqrt(I(:,:,1)))/numlit;
        opts.R0 = padarray(opts.R0,(N_obj-N)/2);
    end

end

T0 = clock;

fprintf('| iter |  rmse    |\n');
for j=1:20, fprintf('-'); end
fprintf('\n');



%% set up the lpf cutoff freq determined by NA
if length(du) == 1
    du = [du,du];
end
u = [-Nmx/2:Nmx/2-1]*du(2);
v = [-Nmy/2:Nmy/2-1]*du(1);
[u,v] = meshgrid(u,v);
% assume a circular pupil function
w_NA0 = sqrt(u.^2+v.^2)<=um;
w_NA = double(w_NA0);
%% initialization in FT domain
% using the on-axis (brightfield) image since it contains the DC
% information

R = opts.R0; opts.R0 = 0;
err1 = inf;
err2 = 50;
err = [];
iter = 0;

if opts.display
    f1 = figure(78); imagesc(abs(F(R))); axis image; colormap gray; colorbar;
    title('current guess of the amplitude');
    f2 = figure(79); imagesc(angle(F(R))); axis image; colormap jet; colorbar;
    title('current guess of the phase');
%     figure(2); imagesc(log(abs(R))); axis image;
%     title('current guess of the Spectrum'); drawnow;
end

if opts.saveIterResult
    saveas(f1,[opts.out_dir,'\Amp_',num2str(iter),'.png']);
    saveas(f2,[opts.out_dir,'\Ph_',num2str(iter),'.png']);
end


%% main algorithm starts here
% stopping criteria: when relative change in error falls below some value,
% can change this value to speed up the process by using a larger value but
% will trading off the reconstruction accuracy
% error is defined by the difference b/w the measurement and the estimated
% images in each iteration

fprintf('| %2d   | %.2e |\n',iter,err1);

while abs(err1-err2)>opts.tol&&iter<opts.maxIter
    err1 = err2;
    err2 = 0;
    for m = 1:Nimg
        % estimated intensity. Note again the amplitude distribution of the
        % LED is assumed to be known a prior
        
        %%% from Fourier to Spatial
        % estimate the intensity for each mode (point on the LED)
        % initialization
        I_est = 0; % estimated intensity
        fn_est = zeros(Nmy,Nmx,numlit); % estimated field for each mode
        for n = 1:numlit
            % set up the coordinates for each LED
            if ~isinf(Ns(n,m,1))
                % index in spatial freq domain of each plane wave
                cen = cen0+col(Ns(n,m,:));
                
                % crop out the corresponding region of spectrum from the
                % current estimate of the object spectrum
                S = R(cen(1)-N(1)/2:cen(1)+N(1)/2-1,cen(2)-N(2)/2:cen(2)+N(2)/2-1);
                % physically acquired spectrum after lpf due to NA
                S_m = S.*w_NA;
                
                % estimated complex field for each mode
                % scaling factor due to FFT
                % fn_est(:,:,n) = Ft(S_m)/N_obj(1)/N_obj(2)*Nmx*Nmy;
                fn_est(:,:,n) = F(S_m);
                
                % intensity of each sub-images
                I_est = I_est+abs(fn_est(:,:,n)).^2;
            end
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
        
        if opts.update_mode % weighted average
            Rtmp = zeros(N_obj);
            wtmp = zeros(N_obj);
            for n = 1:numlit
                if ~isinf(Ns(n,m,1))
                    % center for each sub-image created by each point on the LED
                    %cen = [N_obj(1)/2+1,N_obj(2)/2+1]+[Ns(n,m,1),Ns(n,m,2)];
                    cen = cen0+col(Ns(n,m,:));
                    
                    % define the spectrum region which will be updated
                    %                 [mm,nn] = meshgrid((p-cen(2))*du(2),(q-cen(1))*du(1));
                    %                 w_NA3 = sqrt(mm.^2+nn.^2)<=um;
                    w_NA2 = padarray(w_NA0,(N_obj-N)/2-(cen0-cen),'pre');
                    w_NA2 = padarray(w_NA2,(N_obj-N)/2+(cen0-cen),'post');
                    
                    % assume all incident plane wave has identical energy
                    wt = 1;
                    wtmp = double(w_NA2)*wt+wtmp;
                    
                    % update the field for nth sub-image
                    fn_update = update_scale.*fn_est(:,:,n);
                    % updated the spectrum of the sub-image
                    Fn_est = Ft(fn_update);
                    % update the estimation of the object spectrum by put back into
                    % the right place
                    
                    tmp = zeros(N_obj);
                    tmp(w_NA2) = Fn_est(w_NA0)*wt;
                    Rtmp = Rtmp+tmp;
                    
%                     figure(456); imagesc(log(abs(Rtmp))); axis image;
%                     title('current guess of the Spectrum')
%                     figure(456); imagesc(wtmp); axis image;
%                     title('current updating region in the Spectrum')
%                     drawnow;
                end
            end
            idx = find(wtmp);
            R(idx) = Rtmp(idx)./wtmp(idx);
        else
            % replace each sub-patch sequentially w/o considering different
            % weights due to non-uniform intensity of the LED
            for n = 1:numlit
                if ~isinf(Ns(n,m,1))
                    % center for each sub-image created by each point on the LED
                    %cen = [N_obj(1)/2+1,N_obj(2)/2+1]+[Ns(n,m,1),Ns(n,m,2)];
                    cen = cen0+col(Ns(n,m,:));
                    
                    % define the spectrum region which will be updated
                    %                 [mm,nn] = meshgrid(p-cen(1),q - cen(2));
                    %                 w_NA2 = sqrt(mm.^2+nn.^2)<N_NA/2;
                    w_NA2 = padarray(w_NA,(N_obj-N)/2-(cen0-cen),'pre');
                    w_NA2 = padarray(w_NA2,(N_obj-N)/2+(cen0-cen),'post');
                    
                    % update the field for nth sub-image
                    fn_update = update_scale.*fn_est(:,:,n);
                    % updated the spectrum of the sub-image
                    Fn_est = Ft(fn_update);
                    % update the estimation of the object spectrum by put back
                    % into the right place
                    R(w_NA2) = Fn_est(w_NA>0);
                    
                    %                     figure(2); imagesc(log(abs(R))); axis image;
                    %                     title('current guess of the Spectrum')
                end
            end
            
        end
        
        
%         figure(2); imagesc(log(abs(R))); axis image;
%         title('current guess of the Spectrum')
%         
        %         % display results
        %         figure(88); imagesc(abs(Ft(R))); axis image; colormap gray; colorbar;
        %         title('current guess of the amplitude');
        %         figure(89); imagesc(angle(Ft(R))); axis image; colormap gray; colorbar;
        %         title('current guess of the phase');
        % print diagnostics
        
    end
    % record the error and can check the convergence later.
    err = [err,err2];
    iter = iter+1;
    
    fprintf('| %2d   | %.2e |\n',iter,err2);
    
    if opts.display
        % display results
        f1 = figure(78); imagesc(abs(F(R))); axis image; colormap gray; colorbar;
        title(['current guess of the amplitude, iter=',num2str(iter)]);
        f2 = figure(79); imagesc(angle(F(R))); axis image; colormap jet; colorbar;
        title('current guess of the phase');
        %         figure(2); imagesc(log(abs(R))); axis image;
        %         title('current guess of the Spectrum')
    end
    
    if opts.saveIterResult
        saveas(f1,[opts.out_dir,'\Amp_',num2str(iter),'.png']);
        saveas(f2,[opts.out_dir,'\Ph_',num2str(iter),'.png']);
    end
    
    if opts.monotone&&iter>opts.minIter
        if err2>err1
            break;
        end
    end
    
    
end

r = F(R);

fprintf('elapsed time: %.0f seconds\n',etime(clock,T0));

end

