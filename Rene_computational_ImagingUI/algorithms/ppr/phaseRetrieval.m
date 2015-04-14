function E = phaseRetrieval( images, params, settings, callbacks )
%PHASERETRIEVAL Summary of this function goes here
%   images: nxnxm matrix consisting of m nxn images
%   params: 1xm vector of structs, each struct is the parameters for the
%           corresponding image
%   settings: a struct with additional settings
%       - NA, wavelength, aberrations, pixel_size, lambda, noise_damping
%{
    Results is a struct consisting of the following fields:
        error.fourier
        error.real
        reconstruction

    settings used:
        error_threshold = inf -- frequencies with errors above this value
                                 are zeroed
        lambda = [0;0] -- This is a term in the least squares. Larger
                          values will bias the frequencies towards zero.
        threshold = 10 -- This is the value the diagonals of the matrix
                          must have to be filtered out as noise. A higher
                          value means less filtering.
        threshold_mode = 'total' or 'independent' -- whether to
                            independently threshold the real or imaginary
                            results. If 'independent' the real part could
                            be zeroed due to the threshold, while the
                            imaginary value is kept.
        
        Filtering noise: Some frequencies lie outside the NA and should be
            zero. This procedure removes that noise. If filter_noise is 1
            then any frequencies that should be zero but aren't are marked
            as noise. All frequencies then have filter_noise_threshold
            multiplied by the mean noise subtracted. All frequencies that
            should be zero are set to zero.
                filter_noise = 0
                filter_noise_threshold = 1
        
        The algorithm runs over cutoff_iterations. The iteration progress
        is reported to gradation_fn relative to iterations
            cutoff_iterations
            iterations = cutoff_iterations
            gradation_fn
        
        The transfer function can be subsampled to give a higher resolution.
            tf_subsample
        
        normalization_method = 'assumed'
        mask
        reconstruction_mode = 'full' or 'model' -- whether to use a full 
                                simulation when calculating the error or
                                whether to use the transfer function as
                                a shortcut.
%}

n = size(images, 1) ; m = size(images, 3) ;

callbacks.status ('Starting phase retrieval...') ;
callbacks.progress(0) ;

if isfield(callbacks,'error')
    error_metric_options = callbacks.error() ;
    if isfield(settings,'metric_border'), error_metric_options.crop = settings.metric_border ; end
    if isfield(settings,'metric'), error_metric_options.metric = settings.metric ; end
    if isfield(settings,'metric_filter'), error_metric_options.filter = settings.metric_filter; end
    if error_metric_options.crop == 0
        crop_str = 'no border cropping' ;
    elseif error_metric_options.crop > 1
        crop_str = sprintf('%.0fpx border cropping', round(error_metric_options.crop(1))) ;
    else
        crop_str = sprintf('%.0fpx border cropping', round(size(images,1) * error_metric_options.crop)) ;
    end
    if isinf(error_metric_options.filter)
        filter_str = 'no filtering' ;
    else
        filter_str = sprintf('filtering to < %.1f&middot;NA', error_metric_options.filter) ;
    end
    if ~isfield(settings,'metric_border') && ~isfield(settings,'metric') && ~isfield(settings,'metric_filter')
        callbacks.status(sprintf('<font color="#B54300">Using %s error metric with %s and %s based on GUI values. Specify in the xml file using ''metric'', ''metric_border'', and ''metric_filter''.</font>', error_metric_options.metric, crop_str, filter_str)) ;
    else
        callbacks.status(sprintf('Using %s error metric with %s and %s.', error_metric_options.metric, crop_str, filter_str)) ;
    end
end
if ~isfield(settings, 'iterations') || isnan(settings.iterations), settings.iterations = 10 ; end
if ~isfield(settings, 'error_threshold'), settings.error_threshold = inf ; end
if ~isfield(settings, 'filter_noise'), settings.filter_noise = 0 ; end
if ~isfield(settings, 'filter_noise_threshold'), settings.filter_noise_threshold = 1 ; end

if ~isfield(settings,'enable_plot'), settings.enable_plot = 1 ; end
if strcmp(settings.enable_plot,'on'), settings.enable_plot = 1 ; end

%% Tikhonov Regularization
    if ~isfield(settings,'lambda') || length(settings.lambda) ~= 2
        settings.lambda = [0;0] ;
    else
        settings.lambda = settings.lambda(:) ;
    end
    
    
    if ~isfield(settings,'threshold') || (length(settings.threshold) ~= 1 && length(settings.threshold) ~= 2)
        settings.threshold = 10 ; %this is the maximum condition number allowed. This sets what frequencies are attempted to be reconstructed
    end
    if length(settings.threshold) == 1, settings.threshold = [1,1] * settings.threshold ; end
    if ~isfield(settings,'threshold_mode'), settings.threshold_mode = 'independent' ; end

%% Generate the Transfer Function
callbacks.status ('Creating transfer functions...') ;
tf_options = struct('no_dc', 1) ;
if isfield(settings,'tf_subsample'), tf_options.subsample = settings.tf_subsample ; end
tf_re = zeros(n,n,m) ; tf_im = zeros(n,n,m) ; intensity_scaling = zeros(1, m) ;
for i=1:m
    [tf_re(:,:,i), tf_im(:,:,i), ~, intensity_scaling(i)] = ...
                                                calculateTF (n, ...
                                                params{i}.wavelength / params{i}.pixel_size, ...
                                                params{i}.pupil, ...
                                                params{i}.illumination, ...
                                                tf_options) ;
end
[R, A, R_filt, singularity] = regls_precompute (cat(2, reshape(tf_re,n*n,1,m), ...
                                                       reshape(tf_im,n*n,1,m)), ...
                                                settings.lambda, ...
                                                settings.threshold, ...
                                                settings.threshold_mode) ;
R = R(:,:,R_filt) ;
A = A(R_filt,:,:) ;

%% Filter Noise - EXPERIMENTAL
    %this uses unrecoverable frequencies as a measure of the total noise in
    %the system
    if settings.filter_noise
        for i=1:m
            noise_pixels = (abs(tf_re(:,:,i)) + abs(tf_im(:,:,i))) == 0 ; %is pixel just noise?
            imfft = fftshift(fft2(images(:,:,i))) ;
            mean_noise = mean(abs(imfft(noise_pixels))) * settings.filter_noise_threshold ;
            subthreshold_pixels = abs(imfft) <= mean_noise ; %pixels that are well within the noise
            imfft = imfft .* (1 - mean_noise ./ abs(imfft)) ; %subtract the noise from all pixels
            imfft(noise_pixels) = 0 ; %clear noise only pixels
            imfft(subthreshold_pixels) = 0 ; %clear pixels that were in the noise
            images(:,:,i) = abs(ifft2(ifftshift(imfft))) ;
        end
    end

%% Recovery Algorithm
callbacks.status('Begining iterative phase recovery...') ;
clocktime('total', 'clear') ;
clocktime('forward', 'clear') ;
clocktime('plotting', 'clear') ;
clocktime('total', 'start') ;

E = ones(n,n) ;
normalization_factor = ones(1,m) ; %this holds the scaling factor that scales simulated intensity to each image

%get the initial normalization
if ~isfield(settings,'normalization_method'), settings.normalization_method = 'mode' ; end
if ~strcmp(settings.normalization_method, 'assumed')
    for i=1:m
        img = images(:,:,i) ;
        normalization_factor(i) = mean(img(:)) / intensity_scaling(i) ;
        images(:,:,i) = img / normalization_factor(i) ;
    end
end

image_residual = 1-images ;
error = nan(1, settings.iterations) ;
for iter=1:settings.iterations
    callbacks.progress((iter-1)/settings.iterations) ;
    if callbacks.canceled()
        if iter == 1, return ; else break ; end
    end
    
    %fit the residual
    [E_new, std_error] = fitField (image_residual, R, A, R_filt) ;
    E = E - E_new ;
    
    %calculate the new residual
    clocktime('forward','start') ;
    for i=1:m
        image_so = pcoh_image(E, params{i}.wavelength / params{i}.pixel_size, params{i}.pupil, params{i}.illumination) ;
        image_residual(:,:,i) = image_so - images(:,:,i) ;
        if i==1
            %figure;imagesc(image_so);
            %figure;imagesc(images(:,:,i)) ;
        end
    end
    clocktime('forward','stop') ;
    
    
    %% Normalize the Images
    if ~strcmp(settings.normalization_method, 'assumed')
        M = zeros(1,m) ;
        for i=1:m
            
            M2 = mean(reshape(image_residual(:,:,i),1,[])) ;
            M2_t = (1 - sqrt(1 - 4*M2)) / 2 ;
            M(i) = M2_t / (1 - M2_t) ;
            
            images(:,:,i) = images(:,:,i) * (M(i) + 1) ;
            normalization_factor(i) = normalization_factor(i) / (1 + M(i)) ;
        end
        E = mean(E(:)) + (mean(M) + 1) * (E - mean(E(:))) ;
        
        %calculate a new residual
        clocktime('forward','start') ;
        for i=1:m
            image_so = pcoh_image(E, params{i}.wavelength / params{i}.pixel_size, params{i}.pupil, params{i}.illumination) ;
            image_residual(:,:,i) = image_so - images(:,:,i) ;
        end
        clocktime('forward','stop') ;
    end
    
    if isfield(callbacks,'error')
        error(iter) = callbacks.error(images, image_residual + images, error_metric_options) ;
    else
        error(iter) = norm(image_residual(:),2) ;
    end
    
    if settings.enable_plot
        clocktime('plotting','start');
        if callbacks.plot(1)
            plot(error, '-o') ; hold on;
            xlabel ('Iteration') ;
            ylabel ('Error') ;
        end

        if callbacks.plot(2)
            %img_E_real = real(E) ;
            img_E_real = abs(squeeze(std_error(1,:,:))) ;
            img_E_real(isinf(img_E_real)) = nan ;
            img_E_real = img_E_real - min(img_E_real(:)) ; img_E_real = img_E_real / max(img_E_real(:)) ;
            %img_E_imag = imag(E) ; 
            img_E_imag = abs(squeeze(std_error(2,:,:))) ;
            img_E_imag(isinf(img_E_imag)) = nan ;
            img_E_imag = img_E_imag - min(img_E_imag(:)) ; img_E_imag = img_E_imag / max(img_E_imag(:)) ;
            img_E_real_ft = removeDC(abs(fftshift(fft2(real(E)))),'nan') ; img_E_real_ft = img_E_real_ft - min(img_E_real_ft(:)) ; img_E_real_ft = img_E_real_ft / max(img_E_real_ft(:)) ;
            img_E_imag_ft = removeDC(abs(fftshift(fft2(imag(E)))),'nan') ; img_E_imag_ft = img_E_imag_ft - min(img_E_imag_ft(:)) ; img_E_imag_ft = img_E_imag_ft / max(img_E_imag_ft(:)) ;
            image(real2rgb([img_E_real, img_E_imag; img_E_real_ft, img_E_imag_ft], jet(256))) ;
            axis image;
            set(gca, 'XTick', [], 'YTick', []) ;
            %title (sprintf('[%f, %f]', min(img(:)), max(img(:)))) ;
        end
        clocktime('plotting','stop');
    end
    
    if iter > 1 && (error(iter) > error(iter - 1))
        %rollback all the changes from this iteration
        E = mean(E(:)) + (E - mean(E(:))) / (mean(M) + 1) ;
        E = E + E_new ;
        for i=1:m
            images(:,:,i) = images(:,:,i) / (M(i) + 1) ;
            normalization_factor(i) = normalization_factor(i) * (1 + M(i)) ;
        end
        callbacks.status(sprintf('<span color="red">Error Increasing: rolling back iteration %d</span>', iter)) ;
        callbacks.status(sprintf('M: %f &plusmn; %f', mean(M), std(M))) ;
        callbacks.status(sprintf('Max Update (%%): %.2f', max(reshape( abs(E_new) ./ abs(E) ,1,[])) * 100)) ;
        break ;
    end
end
clocktime('total','stop') ;
callbacks.progress(1) ;
callbacks.status('Finished iterating...') ;
if settings.enable_plot
    callbacks.status(sprintf('Iterating took %.0f sec (%.0f sec for forward propagating, %.0f sec for fitting, %.0f sec for plotting)', clocktime('total'), clocktime('forward'), clocktime('total') - clocktime('forward') - clocktime('plotting'), clocktime('plotting'))) ;
else
    callbacks.status(sprintf('Iterating took %.0f sec (%.0f sec for forward propagating, %.0f sec for fitting)', clocktime('total'), clocktime('forward'), clocktime('total') - clocktime('forward'))) ;
end

%% Export Results
    %Generate Images to compare to original
    if ~isfield(settings,'reconstruction_mode'), settings.reconstruction_mode = 'full' ; end
    if callbacks.canceled(), settings.reconstruction_mode = 'model' ; end
    switch settings.reconstruction_mode
        case 'full'
            for i=1:m
                images(:,:,i) = pcoh_image(E, params{i}.wavelength / params{i}.pixel_size, params{i}.pupil, params{i}.illumination) * normalization_factor(i) ;
            end
        case 'model'
            E_fft_re = removeDC(fftshift(fft2(real(E)))) ;
            E_fft_im = removeDC(fftshift(fft2(imag(E)))) ;
            I_0 = abs(mean(E(:)))^2 ;
            for i=1:m
                images(:,:,i) = (real(I_0 * intensity_scaling(i) + ifft2(ifftshift(E_fft_re .* tf_re(:,:,i))) + ifft2(ifftshift(E_fft_im .* tf_im(:,:,i))))) * normalization_factor(i) ;
            end
    end
    callbacks.result('reconstruction', images) ;

    E = E / mean(E(:)) ;
    std_error = reshape(std_error, 2, n, n) ;

    callbacks.result('field', 'Recovered (Real)', real(E)) ;
    callbacks.result('field', 'Recovered (Imag)', imag(E)) ;
    callbacks.result('field', 'Recovered (Amplitude)', abs(E)) ;
    callbacks.result('field', 'Recovered (Phase)', normAngle(E)*180/pi) ;
    callbacks.result('fourier', 'Fit Error (Real)', squeeze(abs(std_error(1,:,:)))) ;
    callbacks.result('fourier', 'Fit Error (Imag)', squeeze(abs(std_error(2,:,:)))) ;
    callbacks.result('fourier', 'Sensitivity (Re)', reshape(singularity(1,:),n,n)) ;
    callbacks.result('fourier', 'Sensitivity (Im)', reshape(singularity(2,:),n,n)) ;
    switch settings.threshold_mode
        case 'total'
            callbacks.result('fourier', 'Recovered Frequencies', reshape(R_filt,n,n)) ;
        case 'independent'
            callbacks.result('fourier', 'Recovered Frequencies (Real)', reshape(singularity(1,:) < settings.threshold(1),n,n)) ;
            callbacks.result('fourier', 'Recovered Frequencies (Imag)', reshape(singularity(2,:) < settings.threshold(2),n,n)) ;
    end

    if m <= 4
        %for small numbers of fields we can show the transfer functions too
        for i=1:m
            callbacks.result('fourier', sprintf('TF Real (%d)', i), squeeze(tf_re(:,:,i))) ;
            callbacks.result('fourier', sprintf('TF Imag (%d)', i), squeeze(tf_im(:,:,i))) ;
        end
    end


    % If debugging algorithm
    if isfield(settings,'mask')
        mask = settings.mask ;
        mask = mask / mean(mask(:)) ;
        switch settings.threshold_mode
            case 'total'
                recoverable_mask = ifft2(ifftshift(  fftshift(fft2(mask))  .*  reshape(R_filt,n,n)  )) ;
            case 'independent'
                recoverable_mask = ifft2(ifftshift(  fftshift(fft2(real(mask)))  .*  reshape(singularity(1,:) < settings.threshold(1),n,n)  )) + ...
                              1i * ifft2(ifftshift(  fftshift(fft2(imag(mask)))  .*  reshape(singularity(2,:) < settings.threshold(2),n,n)  )) ;
        end
        recoverable_mask = recoverable_mask - mean(recoverable_mask(:)) + mean(mask(:)) ;
        
        callbacks.result('field', 'Mask (Real)', real(mask)) ;
        callbacks.result('field', 'Mask (Imag)', imag(mask)) ;
        callbacks.result('field', 'Mask (Amplitude)', abs(mask)) ;
        callbacks.result('field', 'Mask (Phase)', normAngle(mask)*180/pi) ;
        callbacks.result('field', 'Recoverable Mask (Real)', real(recoverable_mask)) ;
        callbacks.result('field', 'Recoverable Mask (Imag)', imag(recoverable_mask)) ;
        callbacks.result('field', 'Recoverable Mask (Amplitude)', abs(recoverable_mask)) ;
        callbacks.result('field', 'Recoverable Mask (Phase)', normAngle(recoverable_mask)*180/pi) ;
        callbacks.result('field', 'Recoverable Mask Error (Real)', real(recoverable_mask)-real(E)) ;
        callbacks.result('field', 'Recoverable Mask Error (Imag)', imag(recoverable_mask)-imag(E)) ;
        callbacks.result('field', 'Recoverable Mask Error (Amplitude)', abs(recoverable_mask)-abs(E)) ;
        callbacks.result('field', 'Recoverable Mask Error (Phase)', (angle(recoverable_mask)-angle(E))*180/pi) ;
        callbacks.result('field', 'Mask Error (Real)', real(mask - E)) ;
        callbacks.result('field', 'Mask Error (Imag)', imag(mask - E)) ;
        callbacks.result('field', 'Mask Error (Amplitude)', abs(mask) - abs(E)) ;
        callbacks.result('field', 'Mask Error (Phase)', (angle(mask)-angle(E))*180/pi) ;
        callbacks.result('fourier', 'Mask', abs(fftshift(fft2(mask))/length(mask))) ;
        callbacks.result('fourier', 'Recoverable Mask', abs(fftshift(fft2(recoverable_mask))/length(recoverable_mask))) ;


        %E_fft2     = reshape(E_fft,     2, n, n) ;
        %E_fft = zeros(n,n,2) ; E_fft(:,:,1) = E_fft2(1,:,:) ; E_fft(:,:,2) = E_fft2(2,:,:) ;
        %callbacks.result('inspect_fourier', @(x,y)visualizeTFfit(x,y,images,tf_re,tf_im,E_fft,mask)) ;
    else

        %E_fft2     = reshape(E_fft,     2, n, n) ;
        %E_fft = zeros(n,n,2) ; E_fft(:,:,1) = E_fft2(1,:,:) ; E_fft(:,:,2) = E_fft2(2,:,:) ;
        %callbacks.result('inspect_fourier', @(x,y)visualizeTFfit(x,y,images,tf_re,tf_im,E_fft)) ;
    end

callbacks.status('Phase recovery complete.') ;
end

function [E, std_error] = fitField (images, R, A, filt)
    n = size(images,1) ;
    E_fft = zeros(2,n*n) ;
    std_error = inf(2,n*n) ;
    
    images_fft = reshape(fftshift(fftshift(fft2(images),1),2),  n*n,[]) ;
    [E_fft(:,filt), std_error(:,filt)] = regls_parallel (R, A, images_fft(filt,:)) ;
    
    %E_fft = E_fft .* (1 - min(ones(size(std_error)), abs(std_error) ./ abs(E_fft))) ;
    %E_fft(isnan(E_fft) | isinf(E_fft)) = 0 ;
    
    E_fft = conj(E_fft) ;
    E = ifft2(ifftshift(reshape(E_fft(1,:),n,n))) + ...
        ifft2(ifftshift(reshape(E_fft(2,:),n,n))) * 1i ;
    %E = rot90(E,2) ;
    
    std_error = reshape(std_error, 2, n, n) ;
end

function [R, A, filt, singularity] = regls_precompute (A, lambda, threshold, threshold_mode)
    %A is a [nx2xm] matrix
    %R is a [2x2xn] matrix
    %filt is [1xn] and has zero everywhere that R is singular
    
    switch threshold_mode
        case 'total'
            threshold_mode = 1 ; %filter out frequencies that are degenerate in both real/imag
        case 'independent'
            threshold_mode = 2 ; %filter out frequencies that are degenerate in one or both real/imag
        otherwise
            throw('Invalid Threshold Mode') ;
    end
    
    LL = diag(abs(lambda).^2) ;
    
    n = size(A,1) ;
    R = zeros(2,2,n) ;
    filt = false(1,n) ;
    singularity = zeros(2,n) ;
    for i=1:n
        a = squeeze(A(i,:,:)) ;
        m = a * a' + LL ;
        [U,S,V] = svd(m) ;
        S = S.^-1 ;
        S(isnan(S)) = inf ;
        singularity(:,i) = diag(S) ;
        S = diag(S) ; S(S > threshold(:)) = 0 ; S = diag(S) ;
%        S(S > threshold) = 0 ;
        R(:,:,i) = V*S*U' ;
        filt(i) = ~(sum(singularity(:,i) > threshold(:)) >= threshold_mode) ;
    end
end
function [x, stdx, mse] = regls_parallel (R, A, b)
    %x is a [2xn] matrix - holds the real and imaginary parts for each frequency
    %R is a [2x2xn] matrix
    %A is a [nx2xm] matrix (transposed would be [2xmxn] matrix)
    %b is a [nxm] matrix (this would be an [mxn] matrix, but the way the
    %                     image matrix is reshaped this is simpler)
    
    n = size(b,1) ;
    m = size(b,2) ;
    
    Ab = zeros(2,n) ;
    Ab(1,:) = sum(reshape(A(:,1,:),n,m) .* b, 2)' ;
    Ab(2,:) = sum(reshape(A(:,2,:),n,m) .* b, 2)' ;
    
    x = zeros(2,n) ;
    x(1,:) = (squeeze(R(1,1,:)) .* Ab(1,:)' + squeeze(R(1,2,:)) .* Ab(2,:)')' ;
    x(2,:) = (squeeze(R(2,1,:)) .* Ab(1,:)' + squeeze(R(2,2,:)) .* Ab(2,:)')' ;
    
    mse = zeros(1,n) ;
    stdx = zeros(2,n) ;
    norm_factor = 1 ;% max(1,m-2) ;
    for i=1:n
        mse(i) = sum(reshape(  abs(squeeze(A(i,:,:))' * reshape(x(:,i),[],1) - b(i,:)').^2  , 1, [])) / norm_factor ;
        stdx(:,i) = sqrt(diag(squeeze(R(:,:,i))) * mse(i)) ;
    end
end