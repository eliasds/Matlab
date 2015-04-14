function [ Kre, Kim, f, intensity ] = calculateTF( n_pixels, f_0, pupilfunction, illuminationfunction, options )
%{
    f_0 = wavelength / pixel_size
%}

if ~exist('options','var'), options = struct() ; end

if ~isfield(options, 'subsample'), options.subsample = 1 ; end
if ~isfield(options, 'no_dc'), options.no_dc = 0 ; end

if mod(n_pixels,2) == 1, error ('n_pixels must be even') ; end

n_pixels = n_pixels / 2 ;
n_pixels = n_pixels * options.subsample + floor(options.subsample/2) ;

%------------------------------------------------------------
%---- Fix Units ---------------------------------------------
%------------------------------------------------------------
f = ((-n_pixels):(n_pixels)) * f_0 / (n_pixels*2) ; % this matrix must be odd so we can flip it

[FX, FY] = ndgrid(f, f) ;

%% ----------------------------------------------------------
%---- Caclulate TF ------------------------------------------
%------------------------------------------------------------

if isa(pupilfunction,'function_handle')
    P = pupilfunction(FX, FY) ;
elseif isequal(size(pupilfunction), size(FX))
    P = pupilfunction ;
elseif isequal(size(pupilfunction), size(FX) - 1)
    P = padarray(pupilfunction,[1,1],'symmetric','post') ;
else
    error('pupilfunction must be a function or a matrix of size n_pixels or n_pixels+1') ;
end

if ischar(illuminationfunction)
    switch illuminationfunction
        case 'incoherent'
            L = ones(size(FX)) ;
        otherwise
            error ('Invalid illuminationfunction: %s', illuminationfunction) ;
    end
elseif isa(illuminationfunction,'function_handle')
    L = illuminationfunction(FX, FY) ;
elseif isequal(size(illuminationfunction), size(FX))
    L = illuminationfunction ;
elseif isequal(size(illuminationfunction),size(FX) - 1)
    L = padarray(illuminationfunction,[1,1],'symmetric','post') ;
else
    error('illuminationfunction must be a function or a matrix of size n_pixels or n_pixels+1') ;
end
G = P .* L ;

[GP, PG] = xcorr2_same(G, P) ;

Kre = GP + PG ;
Kim = 1i * (GP - PG) ;

Kre = Kre / sum(L(:).^2) ;
Kim = Kim / sum(L(:).^2) ;

if options.subsample ~= 1
    Kre = downsampleC(Kre, options.subsample) ;
    Kim = downsampleC(Kim, options.subsample) ;
    L = downsampleC(L, options.subsample) ;
    G = downsampleC(G, options.subsample) ;
    f = downsampleC(f, options.subsample) ;
    n_pixels = (n_pixels - floor(options.subsample/2)) / options.subsample ;
end

%make the matrices the correct size
n_pixels = 2 * n_pixels ;
Kre = Kre(1:n_pixels,1:n_pixels)  ;% / sum(L(:)) ;
Kim = -Kim(1:n_pixels,1:n_pixels) ;% / sum(L(:)) ;
G = G(1:n_pixels,1:n_pixels) ;% / sum(L(:)) ;
f = f(1:n_pixels) ;

%Kre = real(Kre) ;
%Kim = real(Kim) ;
%I think the TF can be complex, but the final intensity should be forced to
%be real due to rounding errors.

G = abs(G).^2 ;

intensity = sum(G(:)) ;
intensity = intensity / sum(L(:).^2) ;



if options.no_dc
    [~, I] = min(abs(f)) ;
    Kre(I,I) = 0 ;
    Kim(I,I) = 0 ;
end

if isfield(options, 'verify') && options.verify
    if ~exist('pcoh_image'), error('Can''t verify without pcoh_image') ; return; end %#ok<EXIST>
    if ~exist('getPSD'), error('Can''t verify without getPSD') ; return; end %#ok<EXIST>
    PSD = getPSD ('CUTOFF-2D', f, 1e-1, max(abs(f)*sqrt(2))) ;
    [real_msk, nmpp] = getPSD ('2D-REAL', f, PSD, 'real') ;
    img_msk = getPSD ('2D-REAL', f, PSD, 'real') ;
    field = real_msk + 1i * img_msk ;
    field = 1 + field - mean(field(:)) ;
    full_image = pcoh_image( field, 1/nmpp, pupilfunction, illuminationfunction ) ;
    sim_image = real(1 + ifft2(ifftshift(fftshift(fft2(real(field - 1))) .* Kre + fftshift(fft2(imag(field))) .* Kim))) ;
    err = max(abs(full_image(:) - sim_image(:)) ./ full_image(:)) ;
    fprintf('Maximum error during verification is: %.5f%%\n', err*100) ;
    figure;imagesc(full_image-sim_image);colorbar;
    figure;imagesc(full_image);colorbar;
end

end

function [AB, BA] = xcorr2_same (A, B)
    B = conj(rot90(B,2)) ;
    AB = conv2(A,B,'same') ;
    %AB = compact_conv2 (A, B) ;
    BA = conj(rot90(AB,2)) ;
end
function A = compact_conv2 (A, B)
%this does a sparse 2D convolution, it's only been tested for odd matrices
%with size(A) == size(B)
    sz = size(A) ;

    [A, A_pb, A_pa] = compact_matrix(A) ;
    [B, B_pb, B_pa] = compact_matrix(B) ;
    
    pad_before = min (A_pb, B_pb) ;
    pad_after = min(A_pa, B_pa) ;
    
    if isempty(A) || isempty(B)
        A = zeros(sz) ;
    else
        A = conv2(A,B,'full') ;
        A = padarray(padarray(A, pad_before, 'pre'), pad_after, 'post') ;
    end
end

function [A, pad_before, pad_after] = compact_matrix (A)
    x = 1:size(A,1) ; y = 1:size(A,2) ;
    At = abs(A) ;
    xl = sum(At,1) > 0 ; yl = sum(At,2) > 0 ;
    
    xl = [ min(x(xl)), max(x(xl)) ] ;
    yl = [ min(y(yl)), max(y(yl)) ] ;
    
    A = A(xl(1):xl(2), yl(1):yl(2)) ;
    
    pad_before = [xl(1)-1, yl(1)-1] ;
    pad_after  = [length(x) - xl(2), length(y) - yl(2)] ;
end
%}

function M = downsampleC (M, subsample)
    %downsample but exclude the central column
    n = (length(M) - 1 - floor(subsample/2)*2)/2 ;
    
    nl = 1:n ;
    nc = (1:(1+floor(subsample/2)*2)) + max(nl(:)) ;
    nr = (1:n) + max(nc(:)) ;
    
    if size(M,1) == 1
        TL = downsample(M(1,nl), [1,subsample]) ;

        TC = mean(M(1,nc),2) ;

        TR = downsample(M(1,nr), [1,subsample]) ;

        M = [TL TC TR] ;
    elseif size(M,2) == 1
        TL = downsample(M(nl,1), [subsample,1]) ;
        ML = mean(M(nc,1),1) ;
        BL = downsample(M(nr,1), [subsample,1]) ;

        M = [TL; ML; BL] ;
    else
        TL = downsample(M(nl,nl), subsample) ;
        ML = downsample(mean(M(nc,nl),1),[1,subsample]) ;
        BL = downsample(M(nr,nl), subsample) ;

        TC = downsample(mean(M(nl,nc),2), [subsample,1]) ;
        MC = mean(mean(M(nc,nc),1),2) ;
        BC = downsample(mean(M(nr,nc),2), [subsample,1]);

        TR = downsample(M(nl,nr), subsample) ;
        MR = downsample(mean(M(nc,nr),1),[1,subsample]) ;
        BR = downsample(M(nr,nr), subsample) ;

        M = [TL TC TR; ML MC MR; BL BC BR] ;
    end
end
function matrix = downsample (matrix, factor)
    sz = size(matrix) ;
    if length(factor) == 1, factor = [1,1] * factor ; end
    matrix = sum(reshape(matrix, factor(1), []), 1) ; %compact dimension 1
    matrix = reshape(matrix, sz(1)/factor(1), sz(2)) ;
    matrix = reshape(sum(reshape(matrix', factor(2), []), 1),sz(2)/factor(2), sz(1)/factor(1)) ;
    matrix = matrix' / (factor(1) * factor(2)) ;
end
