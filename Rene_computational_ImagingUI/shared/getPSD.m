function [PSD, f] = getPSD( type, varargin )
%GETPSD Manipulate different PSD
%   Syntax: [PSD, f] = getPSD (mode, ...)
%   Modes:
%       1. ISO-2D: [PSD, f] = getPSD ('ISO-2D', f_out, f_in, psd)
%           Given a 1D radially averaged PSD produce a 2D PSD.
%           args: f_out - can be [] to get automatically
%                 f_in
%                 1D PSD
%       2. 2D-ISO: [PSD, f] = getPSD ('2D-ISO', f_in, psd)
%           Given a 2D PSD produce a 1D radially averaged PSD.
%           args: f_in
%                 2D PSD
%       3. CUTOFF-ISO: PSD = getPSD ('CUTOFF-ISO', f_in, rms, cutoff_freq, slope_1, slope_2)
%           Get a 1D radially averaged PSD with the given rms roughness and cutoff frequency.
%           args: f_in - can be [] to get automatically
%                 rms roughness - the integrated area
%                 cutoff frequency - the frequency of the elbow
%                 slope_1 - default: 0
%                 slope_2 - default: infinity
%       3. CUTOFF-2D: PSD = getPSD ('CUTOFF-2D', f_in, rms, cutoff_freq, slope_1, slope_2)
%           Get a 2D PSD with the given rms roughness and cutoff frequency.
%           args: f_out
%                 rms roughness
%                 cutoff frequency
%                 slope_1 - default: 0
%                 slope_2 - default: -infinity
%       4. REAL-2D: [PSD, f] = getPSD ('REAL-2D', pixel_size, mask)
%           Given a mask calculate its 2D PSD.
%           args: pixel_size
%                 mask
%       4. REAL-ISO: [PSD, f] = getPSD ('REAL-ISO', pixel_size, mask)
%           Given a mask calculate its 1D PSD.
%           args: pixel_size
%                 mask
%       5. ISO-RMS [rms] = getPSD ('ISO-RMS', f, psd)
%       6. 2D-RMS [rms] = getPSD ('2D-RMS', f, psd, option)
%           Only psd is required. f can be anything. Any NaN values will 
%           be set to 0. If option == 'nomean', the mean value is removed.
%       7. REAL-RMS [rms] = getPSD ('REAL-RMS', pixel_size, mask, option)
%            If option == 'nomean', the mean value is removed.
%       8. 2D-REAL [msk, nmpp] = getPSD ('2D-REAL', f_in, psd [, option])
%           Given a 2D PSD generate a random mask with that PSD.
%           args: f_in - frequency of PSD samples
%                 psd - a 2D PSD
%                 option - 'real' if the mask should be real
%       9. ISO-REAL: [msk, nmpp] = getPSD ('ISO-REAL', n, nmpp, f_in, psd [, option])
%           Given a 1D radially averaged PSD generate a random mask with
%           that PSD.
%           args: n - number of pixels
%                 nmpp - pixel size
%                 f_in - frequency of PSD samples
%                 psd - a 1D radially averaged PSD
%                 option - 'real' if the mask should be real

if ~exist('type','var')
    help getPSD ;
    return ;
end
switch (upper(type))
    case 'ISO-2D'
        %given a 1D psd get a 2D psd
        psd_f = varargin{2} ;
        psd = varargin{3} ;
        f = varargin{1} ;
        if isempty(f)
            f = [-fliplr(psd_f(psd_f>0)), psd_f] ;
        end
        PSD = convert1Dto2D (f, psd_f, psd) ;
        
        %if diff(f(1:2)) > min(diff(psd_f))
        %    warning ('MATLAB:Sampling', 'The 1D PSD has a finer sampling than the 2D PSD. The result may be inacurate.') ;
        %end
    
    case '2D-ISO'
        %given a 2D psd get a 1D psd
        f_in = varargin{1} ;
        psd = varargin{2} ;
        [PSD, f] = convert2Dto1D(f_in, psd) ;
    case 'CUTOFF-ISO'
        f = varargin{1} ;
        rms_roughness = varargin{2} ;
        cutoff_frequency = varargin{3} ;
        if nargin >= 4
            slope_1 = varargin{4} ;
        else
            slope_1 = 0 ;
        end
        if nargin >= 5
            slope_2 = varargin{5} ;
        else
            slope_2 = -inf ;
        end
        if isempty(f)
            CUTOFF = 2 ; %number of decades down to stop caring about the PSD
            N = 256 ; %number of frequency samples
            f = linspace (0, cutoff_frequency * 10^(-CUTOFF / slope_2), N+1) ; f = f(2:end) ;
        end
        PSD = [10.^(polyval([slope_1, 1-slope_1*log10(cutoff_frequency)], log10(f(f <= cutoff_frequency)))), ...
               10.^(polyval([slope_2, 1-slope_2*log10(cutoff_frequency)], log10(f(f > cutoff_frequency))))] ;
        PSD = PSD * (rms_roughness / getPSD('ISO-RMS', f, PSD))^2 ;
    case 'CUTOFF-2D'
        f_in = varargin{1} ;
        rms_roughness = varargin{2} ;
        cutoff_frequency = varargin{3} ;
        [fx,fy] = meshgrid(f_in) ;
        PSD = ((fx.^2 + fy.^2) < cutoff_frequency^2) ;
        PSD = PSD * rms_roughness^2 / sum(PSD(:)) ;
    case 'REAL-2D'
        pixel_size = varargin{1} ;
        msk = varargin{2} ;
        PSD = abs(fftshift(fft2(msk)/length(msk))).^2 ;
        f = ((-length(msk)/2):(length(msk)/2-1)) / (length(msk)*pixel_size) ;
    case 'REAL-ISO'
        [PSD,f] = getPSD ('REAL-2D', varargin{1}, varargin{2}) ;
        [PSD,f] = getPSD ('2D-ISO', f, PSD) ;
    case 'ISO-RMS'
        f_in = varargin{1} ;
        psd = varargin{2} ;
        PSD = sqrt(sum(psd(1:end-1).*diff(f_in).*2.*pi.*f_in(1:end-1))) ;
    case '2D-RMS'
        psd = varargin{2} ;
        if nargin >= 3 && strcmp(varargin{3},'nomean')
            psd(floor(size(psd,1)/2)+1,floor(size(psd,2)/2)+1) = nan ;
        end
        psd(isnan(psd)) = 0 ;
        PSD = sqrt(mean(psd(:))) ;
    case 'REAL-RMS'
        msk = varargin{2} ;
        if nargin >= 3 && strcmp(varargin{3},'nomean')
            msk = msk - mean(msk(:)) ;
        end
        PSD = sqrt(mean(abs(msk(:)).^2)) ;
    case '2D-REAL'
        f_in = varargin{1} ;
        psd = varargin{2} ;
        if length(varargin) >= 3
            option = varargin{3} ;
        else
            option = '' ;
        end
        [PSD,f] = generateRandomMask(f_in, psd, option) ;
    case 'ISO-REAL'
        n = varargin{1} ;
        nmpp = varargin{2} ;
        f_out = ((-n/2):(n/2-1)) / (nmpp * n) ;
        f_in = varargin{3} ;
        psd = varargin{4} ;
        if length(varargin) >= 5
            option = varargin{5} ;
        else
            option = '' ;
        end
        [psd, f_in] = getPSD ('ISO-2D', f_out, f_in, psd) ;
        [PSD, f] = getPSD ('2D-REAL', f_in, psd, option) ;
    otherwise
        error (['Invalid Type: ' type]) ;
end


end


function PSD2 = convert1Dto2D (f, f_in, PSD_in)
    PSD2 = zeros(length(f)) ;
    
    [fx,fy] = meshgrid(f) ;
    fr = fx.^2 + fy.^2 ;
    
    %fr = sqrt(fx.^2 + fy.^2) ;
    %PSD2 = reshape(interp1(f_in, PSD_in, fr(:), 'linear', 0), length(f), length(f)) ;
    %
    f_in   = [-f_in(1), f_in, f_in(end), inf] ;
    PSD_in = [0, PSD_in,0,0] ;
    for i=2:(length(f_in)-1)
        df_p = diff(f_in(i:i+1)) / 2 ;
        df_n = diff(f_in(i-1:i)) / 2 ;
        filt = (fr <  (f_in(i) + df_p)^2) & ...
               (fr >= (f_in(i) - df_n)^2) ;
        PSD2(filt) = PSD_in(i) ;
    end
    %}
    
    df = diff(f(1:2)) ;
    PSD2 = PSD2 * df^2 * length(PSD2)^2 ;
end

function [PSD1, f] = convert2Dto1D (f_in, PSD_in)
    f = f_in(f_in >= 0) ;
    df = diff(f(1:2)) ;
    PSD1 = zeros(1,length(f)) ;
    
    [fx,fy] = meshgrid(f_in) ;
    fr = fx.^2 + fy.^2 ;
    
    for i=1:length(f)
        if i == length(f)
            df_p = 0 ;
        else
            df_p = diff(f(i:i+1)) / 2 ;
        end
        if i > 1
            df_n = diff(f_in(i-1:i)) / 2 ;
        else
            df_n = 0 ;
        end
        filt = (fr <  (f(i) + df_p)^2) & ...
               (fr >= (f(i) - df_n)^2) ;
        PSD1(i) = mean(PSD_in(filt)) ;
    end
    PSD1 = PSD1 / df^2 / length(PSD_in)^2 ;
end
function [ msk, nmpp ] = generateRandomMask( f, PSD, option )
%GENERATERANDOMMASK Generates a random instance of the provided PSD
%   Detailed explanation goes here

if ~exist('option','var')
    option = 'real' ;
end

nmpp = 1/(diff(f(1:2)) * length(PSD)) ;

if strcmpi(option,'real')
    %the resulting field should be real
    msk = exp(1i*2*pi*rand(size(PSD))) ;
    msk = fftshift(fft2(real(ifft2(msk)))) ; %make sure it's got symmetric phase
    msk = msk ./ abs(msk) ;
    msk = msk .* sqrt(PSD) ;
    msk = real(ifft2(ifftshift(msk))) * length(PSD) ;
else
    msk = exp(1i*2*pi*rand(size(PSD))) ;
    msk = msk .* sqrt(PSD) ;
    msk = (ifft2(ifftshift(msk))) * length(PSD) ;
end


end
