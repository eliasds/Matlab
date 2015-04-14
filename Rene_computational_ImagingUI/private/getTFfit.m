function [ fit ] = getTFfit( n, params, options )
%GETTFFIT Summary of this function goes here
%   n: the size of the matrix
%   params: an array of structures containing the parameters
%       wavelength, pixel_size, pupil, illumination
%   options: a struct containing additional fitting options
%       lambda, threshold, threshold_mode, subsample, callbacks
%       input: 'real' or 'fourier'
%       output: 'real' or 'fourier'

if ~isfield(options,'callbacks'), options.callbacks = struct('status',@(x)1, 'progress',@(x)1, 'canceled',@()0) ; end
if ~isfield(options.callbacks,'status'), options.callbacks.status = @(x)1 ; end
if ~isfield(options.callbacks,'progress'), options.callbacks.progress = @(x)1 ; end
if ~isfield(options.callbacks,'canceled'), options.callbacks.canceled = @()0 ; end

if ~isfield(options,'input'), options.input = 'real' ; end
if ~isfield(options,'output'), options.output = 'real' ; end

m = length(params) ;

tf_options = struct('no_dc', 1) ;
if isfield(options,'subsample'), tf_options.subsample = options.subsample ; end

if isfield(options,'tf_re') && isfield(options, 'tf_im')
     intensity_scaling = zeros(1, m) ;
     tf_re = options.tf_re ;
     tf_im = options.tf_im ;
else
    tf_re = zeros(n,n,m) ; tf_im = zeros(n,n,m) ; intensity_scaling = zeros(1, m) ;
    for i=1:m
        if options.callbacks.canceled(), return ; end
        options.callbacks.progress((i-1)/m) ;
        [tf_re(:,:,i), tf_im(:,:,i), ~, intensity_scaling(i)] = ...
                                                    calculateTF (n, ...
                                                    params{i}.wavelength / params{i}.pixel_size, ...
                                                    params{i}.pupil, ...
                                                    params{i}.illumination, ...
                                                    tf_options) ;
    end
    options.callbacks.progress(1) ;
end
options.callbacks.status ('Precomputing inverse...') ;
[R, A, R_filt, singularity] = regls_precompute (cat(2, reshape(tf_re,n*n,1,m), ...
                                                       reshape(tf_im,n*n,1,m)), ...
                                                options.lambda, ...
                                                options.threshold, ...
                                                options.threshold_mode) ;
R = R(:,:,R_filt) ;
A = A(R_filt,:,:) ;

fit = struct('singularity', singularity) ;
fit.intensity_scaling = intensity_scaling ;
fit.get = @(images)fitField(images, R, A, R_filt, options) ;
fit.apply = @(E)propagateField(E, A, R_filt, options) ;

end

function [E, stderror] = fitField (images, R, A, filt, options)
    n = size(images) ;
    E = zeros(2,n(1)*n(2)) ;
    switch options.input
        case 'real'
            images = reshape(fftshift(fftshift(fft2(images),1),2), [],size(images,3)) ;
        case 'fourier'
            images = reshape(images, [],size(images,3)) ;
        otherwise
            error('Invalid input option. Must be ''real'' or ''fourier''.') ;
    end
    if nargout == 1
        E(:,filt) = regls_parallel (R, A, images(filt,:)) ;
    elseif nargout == 2
        [E(:,filt), stderror(:,filt)] = regls_parallel (R, A, images(filt,:)) ;
        stderror = reshape(stderror, 2, n(1), n(2)) ;
    end
    E = reshape(E, 2, n(1), n(2)) ;
    switch options.output
        case 'real'
            E = ifft2(ifftshift(E(1,:,:))) + ...
                ifft2(ifftshift(E(2,:,:))) * -1i ;
        case 'fourier'
        otherwise
            error('Invalid output option. Must be ''real'' or ''fourier''.') ;
    end
end
function [images] = propagateField (E, A, filt, options)
    m = size(A,3) ;
    n = size(E,1) ;
    
    switch options.output
        case 'real'
            E_fft_re = removeDC(fftshift(fft2(real(E)))) ;
            E_fft_im = removeDC(fftshift(fft2(imag(E)))) ;
            I_0 = abs(mean(E(:)))^2 ;
        case 'fourier'
            E_fft_re = E(1,:,:) ;
            E_fft_im = E(2,:,:) ;
            I_0 = 1 ;
        otherwise
            error('Invalid output option. Must be ''real'' or ''fourier''.') ;
    end
    images = zeros(n,n,m) ;
    for i=1:size(A,3)
        img = zeros(n,n) ;
        img(filt) = E_fft_re(filt) .* A(:,1,i) + ...
                    E_fft_im(filt) .* A(:,2,i) ;
        images(:,:,i) = ifft2(ifftshift(img)) + I_0 ;
    end
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
    
    if nargout > 1
        mse = zeros(1,n) ;
        stdx = zeros(2,n) ;
        norm_factor = 1 ;% max(1,m-2) ;
        for i=1:n
            mse(i) = sum(reshape(  abs(squeeze(A(i,:,:))' * reshape(x(:,i),[],1) - b(i,:)').^2  , 1, [])) / norm_factor ;
            stdx(:,i) = sqrt(diag(squeeze(R(:,:,i))) * mse(i)) ;
        end
    end
end