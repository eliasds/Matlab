function [ ] = saveMovie ( m, filename, fps)
%SAVEMOVIE Save a movie to avi properly
if exist('fps', 'var') == 0
    fps = 2.5 ;
end
if fps < 2.5
    fps = 2.5 ;
end
for i=1:length(m)
    s = size(m(i).cdata) ;
    n_s = 2.^ceil(log2(s(1:2))) ;
    pad_s = n_s - s(1:2) ;
    ncdata = zeros([n_s, 3]) ;
    for j=1:3
        ncdata(:,:,j) = padarray(padarray(m(i).cdata(:,:,j), floor(pad_s/2),0,'pre'), ...
                                                             ceil(pad_s/2),0,'post') ;
    end
    m(i).cdata = uint8(ncdata) ;
end
%fps = 15/2.^round(log2(15/fps)) ;
movie2avi(m, filename, 'compression', 'none', 'fps', fps) ;
end