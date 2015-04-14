function [ image ] = pcoh_image( field, f_0, pupilfunction, illuminationfunction )
%PCOH_IMAGE Summary of this function goes here
%   Detailed explanation goes here

    global USE_GPU ;
    if isempty(USE_GPU), USE_GPU = 0 ; end

    n = size(field,1) ;
    f = f_0 * ((-n/2):(n/2-1)) / n ;
    [fx, fy] = meshgrid(f) ;

    P = pupilfunction(fx,fy) ;
    
    if ischar(illuminationfunction) && strcmp(illuminationfunction,'incoherent')
        MTF = real(fftshift(fft2( abs(ifft2(ifftshift(P))).^2 ))) ; %calculate incoherent point spread function
        MTF = MTF / max(MTF(:)) ;
        image = abs(ifft2(ifftshift( MTF .* fftshift(fft2(abs(field).^2)) ))) ;
    else
        L = illuminationfunction(fx,fy) ;
        [S(:,1) S(:,2)] = ind2sub(size(field), find(ifftshift(L) > 0)) ;
        S = S - 1 ;

        if USE_GPU && size(S,1) > 20
            image = pcoh_image_gpu (field, P, S) ;
        else
            image = pcoh_image_cpu (field, P, S) ;
        end
    end
end

function I = pcoh_image_cpu (E, P, S)
    E_fft = fft2(E) ;
    P = ifftshift(P) ;
    I = zeros(size(E)) ;
    for i=1:size(S,1)
        I = I + abs(ifft2(circshift(E_fft, S(i,1:2)) .* P)).^2 ;
    end
    %I = I ./ size(S,1) ;
    %I = I * sum(I(:)) / sum(abs(E(:))) ; %This is just one and doesn't do anything
end

function I = pcoh_image_gpu (E, P, S)
% E: an nxn matrix - the electric field
% P: an nxn matrix - the pupil
% S: an mx2 matrix - x,y shifts of the field
global H ;

gP = gpuArray (P) ;
gS = gpuArray(S) ;

gE_fft = fft2(gpuArray (E)) ;
gI = gpuArray.zeros(size(E)) ;
gX = zeros([size(E), H],'gpuArray') ;
for i=0:H:size(S,1)
    n_shifts = min(H, size(S,1)-i) ;
    for j=1:n_shifts
        gX(:,:,j) = arrayfun(@(x)abs(x).^2, ifft2(circshift(gE_fft, gS(j+i,:)) .* gP)) ;
    end
    gI = gI + sum(gX,3) ;
end
I = gather(gI) ;
%I = gather(gI / size(S,1)) ;
end