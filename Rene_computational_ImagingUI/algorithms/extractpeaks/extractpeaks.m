function [ E, results, images_out ] = extractpeaks( images, params, settings, callbacks )
%COMPARE This function takes the N biggest fourier peaks and finds out
%their frequency and height.

if ~isfield(settings, 'target_size')
    settings.target_size = [2048, 2048] ;
end
if ~isfield(settings, 'N')
    settings.N = 5 ;
end

for i=1:size(images,3)
    [target_fx, target_fy, target_amp] = extractPeaks (images(:,:,i), settings) ;
    callbacks.status(sprintf('Image %d', i)) ;
    for j=1:length(target_fx)
        if target_fx(j) == 0, fx = 'DC' ;
        else fx = sprintf('%.0f <i>nm</i><sup>-1</sup>', 1/target_fx(j)*1e9) ; end
        if target_fy(j) == 0, fy = 'DC' ;
        else fy = sprintf('%.0f <i>nm</i><sup>-1</sup>', 1/target_fy(j)*1e9) ; end
        callbacks.status(sprintf('fx: %s, fy: %s, a: %e', fx, fy, target_amp(j))) ;
    end
end
E = [] ;
results = struct() ;
images_out = images ;
end

function [target_fx, target_fy, target_amp] = extractPeaks (image, settings)
    s = size(image) ;
    target_s = max(s, settings.target_size) ;
    n_s = 2.^ceil(log2(target_s(1:2))) ;
    pad_s = n_s - s(1:2) ;
    
    image = padarray(padarray(image, floor(pad_s/2),0,'pre'), ...
                     ceil(pad_s/2),0,'post') ;
    image_fft = fftshift(fft2(image)) / n_s(1) ;
    [fx, fy] = meshgrid( ((-size(image,1)/2):(size(image,1)/2-1)) / (size(image,1)*settings.pixel_size), ...
                         ((-size(image,2)/2):(size(image,2)/2-1)) / (size(image,2)*settings.pixel_size) ) ;
    [B, I] = sort(abs(image_fft(:)), 'descend') ;
    target_freq = I(1:settings.N) ;
    target_fx = fx(target_freq) ;
    target_fy = fy(target_freq) ;
    target_amp = abs(image_fft(target_freq)) ...
        * (s(1) * settings.pixel_size) * (s(2) * settings.pixel_size) ;
end