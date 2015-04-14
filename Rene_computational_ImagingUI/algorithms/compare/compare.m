function [ E, results, images_out ] = compare( images, params, settings, callbacks )
%COMPARE This function takes the provided field and propagates it to match
%        the provided images

n = size(images, 1) ;
m = size(images, 3) ;
E = zeros(size(images,1),size(images,2)) ;
results = struct() ;

if isfield(settings, 'mask')
    E = settings.mask ;
else
    callbacks.status ('No mask field provided.') ;
    return ;
end

callbacks.status ('Starting propagation...') ;
callbacks.progress(0) ;

images_out = zeros(n,n,m) ;

for i=1:m
    callbacks.progress((i-1)/m) ;
    if callbacks.canceled()
        if i == 1, return ; else break ; end
    end
    img = pcoh_image(E, params{i}.wavelength / params{i}.pixel_size, params{i}.pupil, params{i}.illumination) ;
    sel_area_x = floor((size(img,1)-size(images_out,1))/2+1):ceil(size(img,1) - (size(img,1)-size(images_out,1))/2) ;
    sel_area_y = floor((size(img,2)-size(images_out,2))/2+1):ceil(size(img,2) - (size(img,2)-size(images_out,2))/2) ;
    images_out(:,:,i) = img(sel_area_x, sel_area_y) ;
    [images_out(:,:,i), offset, scale] = minimizeImageDifference (images(:,:,i), images_out(:,:,i)) ;
    callbacks.status(sprintf('Image %d fit best with scaling %.2e and offset %.2f', i, scale, offset)) ;
end
callbacks.progress(1) ;
callbacks.status('Finished propagating...') ;

%% Export Results
results.reconstruction = images_out ;

E = E / mean(E(:)) ;
results.fields = {'Mask (Real)',      real(E); ...
                  'Mask (Imag)',      imag(E); ...
                  'Mask (Amplitude)', abs(E); ...
                  'Mask (Phase)',     angle(E)*180/pi;} ;

callbacks.status('Complete.') ;
end

function [image, offset, scale] = minimizeImageDifference (ref_image, image)
    target_image = image(:) ;
    ref_image = ref_image(:) ;
    x = fminsearch (@(x)sum(abs(ref_image-target_image*x(1)-x(2))), [1,0], ...
                    struct('MaxIter', 300, 'TolX', 1e-2)) ;
    offset = x(2) ;
    scale = x(1) ;
    image = image*scale + offset ;
end