function [ fft_arg, DC ] = removeDC( fft_arg, option )
%REMOVEDC Remove the DC component of a fourier spectrum
%   The spectrum has already been fftshifted
setval = 0 ;
if exist('option','var')
    switch option
        case 'nan'
            setval = nan ;
        
    end
end

if isempty(fft_arg)
    DC = nan ;
else
    DC = fft_arg(floor(size(fft_arg,1)/2)+1,floor(size(fft_arg,2)/2)+1) ;
end
fft_arg(floor(size(fft_arg,1)/2)+1,floor(size(fft_arg,2)/2)+1) = setval ;

end

