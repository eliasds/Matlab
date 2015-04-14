function [ E, results, images ] = gs( images, params, settings, callbacks )
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
        N: Number of loops to perform
            default: 100
%}

if ~isfield(settings,'N'), settings.N = 100 ; end

num_imgs = size(images, 3) ;
zvec = arrayfun(@(x)x{1}.defocus, params) ;
N = settings.N ;

ps = arrayfun(@(x)x{1}.pixel_size, params) ;
if sum(abs(diff(ps))) > 0, error('Pixel size must be constant between images.') ; end
ps = mean(ps) ;

lambda = arrayfun(@(x)x{1}.wavelength, params) ;
if sum(abs(diff(lambda))) > 0, error('Wavelength must be constant between images.') ; end
lambda = mean(lambda) ;

[~, I0_idx] = min(abs(zvec)) ;
amp = sqrt(images(:,:,I0_idx)) ;

num_imgs = min(length(params) - I0_idx, I0_idx - 1) ;

callbacks.status (sprintf('Starting phase retrieval using Gerchberg-Saxton with %d iterations...', N)) ;
tic ;
phi = gs_multiple_plane( images, I0_idx, zvec(:), num_imgs, ps, lambda, N, callbacks ) ;
callbacks.status ('Iteration complete.') ;
callbacks.status(sprintf('Iterating took %.0f sec', toc)) ;

E = amp .* exp(1i*phi) ;

%% Export Results
results = struct('fields',struct()) ;

%Generate Images to compare to original
if ~isfield(settings,'reconstruction_mode'), settings.reconstruction_mode = 'none' ; end
if callbacks.canceled(), settings.reconstruction_mode = 'none' ; end
switch settings.reconstruction_mode
    case 'full'
        images_cur = zeros(size(images)) ;
        callbacks.status('Reconstructing Images...') ;
        callbacks.progress(0) ; tic;
        for i=1:length(params)
            images_cur(:,:,i) = pcoh_image(E, params{i}.wavelength / params{i}.pixel_size, params{i}.pupil, params{i}.illumination) ;
            callbacks.progress(i/length(params)) ;
        end
        results.reconstruction = images_cur ;
        callbacks.status(sprintf('Reconstruction Complete (%.0f sec)', toc)) ;
    case 'none'
end

E = E / mean(E(:)) ;
results.fields = {'Recovered (Real)',      real(E); ...
                  'Recovered (Imag)',      imag(E); ...
                  'Recovered (Amplitude)', amp; ...
                  'Recovered (Phase)',     phi*180/pi;} ;
results.fields_fourier = {} ;
if isfield(settings,'mask')
    mask = settings.mask ;
    results.fields = [results.fields;
                      {'Mask (Real)', real(mask); ...
                       'Mask (Imag)', imag(mask); ...
                       'Mask (Amplitude)', abs(mask); ...
                       'Mask (Phase)', angle(mask)*180/pi; ...
                       'Mask Error (Real)',(real(mask)-real(E)); ...
                       'Mask Error (Imag)',(imag(mask-E)); ...
                       'Mask Error (Amplitude)',(abs(mask)-abs(E));...
                       'Mask Error (Phase)',(angle(mask)-angle(E))*180/pi}] ;
    results.fields_fourier = [results.fields_fourier;
                              {'Mask', abs(fftshift(fft2(mask))/length(mask));}] ;
end

callbacks.status('Phase recovery complete.') ;
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