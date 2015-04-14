function E = sourcepupilextraction( images, params, settings, callbacks )
%SOURCEPUPILEXTRACTION Extract the source and pupil shape from the images
%   It is assumed that we are dealing with a weak object. Under that
%   assumption gradient descent is performed on the illumination, the pupil
%   phase, and the pupil appodization
%
%   The pixel_size, wavelength, and illumination must be the same for each
%   image.
%   settings: illumination - this gives the maximum illumination to try to
%                            find, can be a function or a matrix


n = size(images, 1) ; m = size(images, 3) ;

pixel_size = params{1}.pixel_size ;
wavelength = params{1}.wavelength ;

if ~isfield(settings,'illumination'), error('Required setting illumination not provided.') ; end
if isa(settings.illumination,'function_handle')
    f = (ceil(-n/2):ceil(n/2-1))/(n*pixel_size) * wavelength ;
    [FX, FY] = ndgrid(f, f) ;
    recoverable_illumination = settings.illumination(FX,FY) ;
elseif isequal(size(settings.illumination),[size(images,1),size(images,2)])
    recoverable_illumination = settings.illumination ;
else
    error ('settings.illumination is invalid') ;
end

if ~isfield(settings,'iterations'), settings.iterations = 2 ; end
if ~isfield(settings,'lambda') || length(settings.lambda) ~= 2
    settings.lambda = [0;0] ;
else
    settings.lambda = settings.lambda(:) ;
end
if ~isfield(settings,'threshold') || (length(settings.threshold) ~= 1 && length(settings.threshold) ~= 2)
    settings.threshold = 10 ; %this is the maximum condition number allowed. This sets what frequencies are attempted to be reconstructed
end
if ~isfield(settings,'threshold_mode'), settings.threshold_mode = 'total' ; end

tf_options = struct('no_dc', 1) ;
il = find(recoverable_illumination ~= 0) ;
tf_re = zeros(n,n,m,length(il)) ;
tf_im = zeros(n,n,m,length(il)) ;
intensity_scaling = zeros(m,length(il)) ;
for i=1:length(il)
    for j=1:m
        if callbacks.canceled(), return ; end
        callbacks.progress( ( (i-1)*m+j ) / (length(il) * m)) ;
        illumination = zeros(size(recoverable_illumination)) ;
        illumination(il(i)) = 1 ;
        [tf_re(:,:,j,i), tf_im(:,:,j,i), ~, intensity_scaling(j,i)] = ...
                        calculateTF (n, ...
                        params{j}.wavelength / params{j}.pixel_size, ...
                        params{j}.pupil, ...
                        illumination, ...
                        tf_options) ;
    end
end
callbacks.progress(1) ;

images_fft = fftshift(fftshift(fft2(images),1),2) ;
L = recoverable_illumination ;
for iter=1:settings.iterations
    if callbacks.canceled(), return ; end
    callbacks.progress( (iter - 1) / settings.iterations ) ;
    
    %Extract the field
    fit = getTFfit(n, params, struct('input','fourier', 'output','fourier', ...
                                     'lambda', settings.lambda, 'threshold', settings.threshold, 'threshold_mode', settings.threshold_mode, ...
                                     'tf_re', sum(tf_re .* repmat(reshape(L(il),1,1,1,[]), [n,n,m,1]),4), ...
                                     'tf_im', sum(tf_im .* repmat(reshape(L(il),1,1,1,[]), [n,n,m,1]),4))) ;
    E = fit.get(images_fft) ;
    
    %Extract the illumination
    ILM = zeros(length(il), n, n, m) ;
    I_0 = 1 ;
    for i=1:length(il)
        for j=1:m
            ILM(i,:,:,j) = ...
                real( I_0 * intensity_scaling(j, i) + ...
                      ifft2(ifftshift( squeeze(E(1,:,:)) .* tf_re(:,:,i)) ) + ...
                      ifft2(ifftshift( squeeze(E(2,:,:)) .* tf_im(:,:,i)) )  ) ;
        end
    end
    ILM = reshape(ILM, length(il), []) ;
    L(il) = sparse(ILM') \ sparse(images(:)) ;
end



end
