function [ out ] = tcc_image( varargin )
%TCC_IMAGE This function either precomputes the eigen decomposition of the
%TCC matrix or computes an image based on it.
%   tcc_struct = tcc_image(size, pixel_size, wavelength, pupilfunction, illuminationfunction, options)
%   image = tcc_image(field, tcc_struct, options)
%
%   Available Options:
%       accuracy - a number between 0 and 1 that is used to calculate how
%          many eigenvalues to use
%       eigenvalues - how many eigenvalues to use, an alternative option to
%           accuracy
%       prepare - if set the eigenvectors are shifted and scaled by the
%          eigenvalues, this saves a bit of time during image computation but
%          makes the eigenvectors harder to visualize
%       image - This will combine both function modes imediately generating
%          the image, useful for debugging
%   f_0 = wavelength / pixel_size

    if nargin == 5 || nargin == 6 %get struct
        if nargin < 6, varargin{6} = struct('image',1,'accuracy',0.99) ; end
        if isstruct(varargin{4}), varargin{4} = varargin{4}.fn ; end
        if isstruct(varargin{5}), varargin{5} = varargin{5}.fn ; end
        out = factorTCC(varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}) ;
        if isfield(varargin{6}, 'image') && varargin{6}.image
            out = applyTCC(varargin{1}, out, varargin{6}) ;
        end
    else %get image
        if nargin < 3, varargin{3} = struct() ; end
        out = applyTCC(varargin{1}, varargin{2}, varargin{3}) ;
    end
end
function tcc_struct = factorTCC (field_size, pixel_size, wavelength, pupilfunction, illuminationfunction, options)
    if length(field_size) == 1
        field_size = [1,1] * field_size ;
    else
        field_size = field_size(1:2) ;
    end
    n = field_size(1) ;


    tcc_struct = struct() ;
    f_0 = wavelength / pixel_size ;
    f = f_0 * (floor(-n/2):ceil(n/2-1)) / n ;
    [fx, fy] = ndgrid(f) ;
    L = illuminationfunction(fx,fy) ;
    P = pupilfunction(fx,fy) ;
    [LL(:,1) LL(:,2)] = ind2sub(field_size, find(ifftshift(L) > 0)) ;
    LL = LL - 1 ;
    LL(:,3) = ifftshift(L(L > 0)) ;
    
    
    Poperator = zeros(size(LL,1), numel(fx)) ;
    for i=1:size(Poperator,1)
        Poperator(i,:) = reshape(circshift(P, LL(i,1:2)),1,size(Poperator,2)) * LL(i,3) ;
    end
    not_sparse_col = sum(abs(Poperator),1) > 0 ;
    Poperator(:,sum(abs(Poperator),1)==0) = [] ;
    %{
    %It turns out that svds is actually not faster for large numbers of eigenvalues
    if isfield(options,'eigenvalues') && ~isnan(options.eigenvalues) && ~isinf(options.eigenvalues)
        [~,S,V] = svds(Poperator, min(options.eigenvalues,size(Poperator,2))) ;
    else
        [~,S,V] = svd(Poperator,'econ') ;
    end
    %}
    [~,S,V] = svd(Poperator,'econ') ;
    
    if isfield(options,'accuracy')
        eigenv = diag(S).^2 ;
        eigen_sum = sum(eigenv) ;
        e_conv = 0 ;
        ie = 0 ;
        while e_conv < options.accuracy
            ie = ie + 1 ;
            e_conv = sum(eigenv(1:ie)) / eigen_sum ;
        end
        eigenf_n = ie ;
    elseif isfield(options,'eigenvalues')
        eigenf_n = min(options.eigenvalues, size(S,1)) ;
    else
        eigenf_n = size(S,1) ;
    end
    eigenf = zeros([field_size, eigenf_n]) ;
    for i=1:eigenf_n
        V1D = zeros(field_size) ;
        V1D(not_sparse_col) = V(:,i) ;
        eigenf(:,:,i) = conj(reshape(V1D,field_size)) ;
    end
    if isfield(options,'prepare') && options.prepare
        %preparing does the fftshift and multiplication by the eigenvalue
        %only once to get a small speedup
        for i=1:eigenf_n
            eigenf(:,:,i) = ifftshift(eigenf(:,:,i)) * S(i,i) ;
        end
        tcc_struct.total_intensity = sum(LL(:,3).^2) ;
        eigenf = eigenf / sqrt(tcc_struct.total_intensity) ;
        options.prepare = 1 ;
    else
        tcc_struct.total_intensity = sum(LL(:,3).^2) ;
        options.prepare = 0 ;
    end
    tcc_struct.n = eigenf_n ;
    tcc_struct.eigenvalues = diag(S(1:eigenf_n,1:eigenf_n)) ;
    tcc_struct.eigenfunctions = eigenf ;
    tcc_struct.prepared = options.prepare ;
end
function image = applyTCC (field, tcc_struct, options)
    image = zeros(size(field)) ;
    eigenf_n = tcc_struct.n ;
    if tcc_struct.prepared
        field_fft = fft2(field) ;
        for i=1:eigenf_n
            E_fft = field_fft .* tcc_struct.eigenfunctions(:,:,i) ;
            E = ifft2(E_fft) ;
            image = image + E .* conj(E) ;
        end
    else
        field_fft = fftshift(fft2(field)) ;
        for i=1:eigenf_n
            E_fft = field_fft .* tcc_struct.eigenfunctions(:,:,i) * tcc_struct.eigenvalues(i) ;
            E = ifft2(ifftshift(E_fft)) ;
            image = image + E .* conj(E) ;
        end
        image = image / tcc_struct.total_intensity ;
    end
    if sum(imag(image(:))) > 0
        fprintf('Image has imaginary part: %f\n', sum(imag(image(:)))) ;
    end
    if sum(isnan(image(:))) > 0
        fprintf('ERROR\n') ;
    end
end
