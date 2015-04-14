function [ ] = saveMovie ( m, filename, fps, bg_color)
%SAVEMOVIE Save a movie to avi properly
vlcpath = 'C:\Program Files (x86)\VideoLAN\VLC\' ;

if ~exist('fps', 'var'), fps = 2.5 ; end
if ~exist('bg_color','var'), bg_color = 'k' ; end
switch bg_color
    case 'w', bg_color = [1,1,1] ;
    case 'k', bg_color = [0,0,0] ;
    otherwise, if ischar(bg_color), error('Background color must be a color vector or w (white) or k (black)') ; end
end
if max(bg_color) <= 1, bg_color = bg_color * 255 ; end

[~, ~, ext] = fileparts (filename) ;

for i=1:length(m)
    s = size(m(i).cdata) ;
    if sum(nextpow2(s(1:2)-2) < nextpow2(s(1:2)))
        m(i).cdata = m(i).cdata(2:end-1,2:end-1,:) ; %remove border from getframe
    end
end

switch ext
    case '.avi'
        if fps < 2.5, fps = 2.5 ; end %min fps for video to work ok
    
        if exist([vlcpath 'vlc.exe'], 'file')
            tempn = [tempname '.avi'] ;
            writerObj = VideoWriter(tempn, 'Uncompressed AVI') ;
            writerObj.FrameRate = fps ;
            open(writerObj) ;
            
            while ~isempty(m)
                mm = m(1) ;
                m(1) = [] ;
                s = size(mm.cdata) ;
                n_s = 2.^ceil(log2(s(1:2))) ;
                pad_s = n_s - s(1:2) ;
                ncdata = zeros([n_s, 3]) ;
                for j=1:3
                    ncdata(:,:,j) = padarray(padarray(mm.cdata(:,:,j), floor(pad_s/2),bg_color(j),'pre'), ...
                                                                       ceil(pad_s/2),bg_color(j),'post') ;
                end
                mm.cdata = uint8(ncdata) ;
                writeVideo(writerObj, mm) ;
            end
            close(writerObj) ;
            filename = strrep(filename, '/', '\');
            [~,~] = system (['"' vlcpath 'vlc.exe" "' tempn '" --sout=#transcode{vcodec=wmv2,vb=' num2str(round(60*25*n_s(1)*n_s(2)/256)) '}:standard{access=file,mux=avi,dst="' filename '"} vlc://quit']) ;
            delete (tempn) ;
        else
            writerObj = VideoWriter(filename, 'Motion JPEG AVI') ;
            writerObj.FrameRate = fps ;
            open(writerObj) ;
            
            while ~isempty(m)
                mm = m(1) ;
                m(1) = [] ;
                s = size(mm.cdata) ;
                n_s = 2.^ceil(log2(s(1:2))) ;
                pad_s = n_s - s(1:2) ;
                ncdata = zeros([n_s, 3]) ;
                for j=1:3
                    ncdata(:,:,j) = padarray(padarray(mm.cdata(:,:,j), floor(pad_s/2),bg_color(j),'pre'), ...
                                                                       ceil(pad_s/2),bg_color(j),'post') ;
                end
                mm.cdata = uint8(ncdata) ;
                writeVideo(writerObj, mm) ;
            end
            close(writerObj) ;
        end
    case '.mp4'
        try
            writerObj = VideoWriter(filename, 'MPEG-4') ;
            writerObj.FrameRate = fps ;
            writerObj.Quality = 80 ;
            open(writerObj) ;
            for i=1:length(m)
                writeVideo(writerObj, m(i)) ;
            end
            close(writerObj) ;
        catch %#ok<CTCH>
            error ('Unable to save as mp4') ;
        end
    case '.gif'
        delaytime = max(0, min(655, 1 / fps)) ;
        for i=1:length(m)
            im = frame2im(m(i)) ;
            [imind,cm] = rgb2ind(im,256) ;
            if i == 1
                imwrite(imind,cm,filename,'gif', 'Loopcount', inf, 'DelayTime', delaytime) ;
            else
                imwrite(imind,cm,filename,'gif','WriteMode','append') ;
            end
        end
    otherwise
        error('Invalid file type') ;
end
    


end

