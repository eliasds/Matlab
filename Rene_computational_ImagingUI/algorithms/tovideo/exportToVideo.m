function [ E, results, images ] = exportToVideo( images, params, settings, callbacks )

E = 0 ;
results = struct() ;


if size(settings,3) == 0, return ; end

if ~isdir(settings.path), settings.path = ['../../' settings.path] ; end
if ~isfield(settings,'colormap'), settings.colormap = 'gray' ; end
if ~isfield(settings,'fps'), settings.fps = 4 ; end
if ~isfield(settings,'bg_color'), settings.bg_color = 'k' ; end
if ~isfield(settings,'colorbar'), settings.colorbar = '' ; end
if ~isfield(settings,'plot'), settings.plot = 'real' ; end
if ~isfield(settings,'no_dc'), settings.no_dc = 1 ; end %only for fourier plot
if ~isfield(settings,'crop'), settings.crop = nan ; end %only for fourier plot, fraction of plot to crop
if isfield(settings,'save_to')
    filename = settings.save_to ;
    filename = fullfile(settings.path, filename) ;
else
    [filename, path] = uiputfile('*.avi;*.gif;*.mp4;*.png', 'Save Images to Video', settings.path) ;
    if isequal(filename, 0) || isequal(path, 0), return ;end
    filename = fullfile(path, filename) ;
end

callbacks.status ('Exporting images to video:') ;
callbacks.status (sprintf('Options: colormap=%s, fps=%f, bg_color=%s, colorbar=%f', settings.colormap, settings.fps, num2str(settings.bg_color), num2str(settings.colorbar))) ;
callbacks.status (sprintf('Saving to (save_to) = %s', filename)) ;
callbacks.status ('You may specify a text to show on each image using ''text''.') ;
callbacks.status ('Parameters available to specify the text are: location (top_right, top_left_ bottom_right, bottom_left), color, margin, fontsize') ;

switch settings.plot
    case 'fourier_log'
        for i=1:size(images,3)
            images(:,:,i) = 2*log10(abs(fftshift(fft2(images(:,:,i)) / size(images,1)))) ;
        end
        if settings.no_dc
            images(size(images,1)/2+1,size(images,2)/2+1,:) = nan ;
        end
        if ~isnan(settings.crop)
            images = images(size(images,1)/2+((-1*round(size(images,1)*settings.crop/2)):round(size(images,1)*settings.crop/2-1)), ...
                            size(images,2)/2+((-1*round(size(images,2)*settings.crop/2)):round(size(images,2)*settings.crop/2-1)), :) ;
        end
    case 'fourier'
        for i=1:size(images,3)
            images(:,:,i) = abs(fftshift(fft2(images(:,:,i)) / size(images,1))).^2 ;
        end
        if settings.no_dc
            images(size(images,1)/2+1,size(images,2)/2+1,:) = nan ;
        end
        if ~isnan(settings.crop)
            images = images(size(images,1)/2+((-1*round(size(images,1)*settings.crop/2)):round(size(images,1)*settings.crop/2-1)), ...
                            size(images,2)/2+((-1*round(size(images,2)*settings.crop/2)):round(size(images,2)*settings.crop/2-1)), :) ;
        end
    otherwise %real
        
end

clims = [min(images(:)), max(images(:))] ;
use_text = sum(arrayfun(@(x)isfield(x{1},'text'), params)) > 0 ;
callbacks.status(sprintf('Data limits: [%f, %f]', clims(1), clims(2))) ;


if use_text
    f = figure;
    imagesc(images(:,:,1)) ;
    axis image;
    truesize(f) ;
    M = moviein(size(images,3)) ;
    for i=1:size(images,3)
        if callbacks.canceled(), close (f); return ; end
        cla ;
        imagesc(images(:,:,i)) ;
        colormap(settings.colormap) ;
        axis image;
        truesize(f) ;
        set(gca, 'xtick', [], 'ytick', []) ;
        if strcmp(settings.colorbar,'constant')
            caxis(clims) ;
        elseif length(settings.colorbar) == 2
            caxis(settings.colorbar) ;
        end

        param = params{i} ;
        if isfield(param,'text')
            if ~ischar(param.text), param.text = num2str(param.text) ; end
            if ~isfield(param, 'location'), param.location = 'top_right' ; end
            if ~isfield(param, 'color'), param.color = [1,0,0] ; end
            if ~isfield(param, 'margin'), param.margin = 0.05 ; end
            if ~isfield(param, 'fontsize'), param.fontsize = 18 ; end
            t = text(0,0, param.text, 'Color', param.color, 'FontSize', param.fontsize) ;
            xl = xlim; yl = ylim ;
            xl(1) = xl(1) + param.margin * (xl(2) - xl(1)) ;
            yl(1) = yl(1) + param.margin * (yl(2) - yl(1)) ;
            xl(2) = xl(2) - param.margin * (xl(2) - xl(1)) ;
            yl(2) = yl(2) - param.margin * (yl(2) - yl(1)) ;
            switch param.location
                case 'top_right'
                    set(t, 'Position', [xl(2), yl(1),0], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top') ;
                case 'top_left'
                    set(t, 'Position', [xl(1), yl(1),0], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top') ;
                case 'bottom_right'
                    set(t, 'Position', [xl(2), yl(2),0], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom') ;
                case 'bottom_left'
                    set(t, 'Position', [xl(1), yl(2),0], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom') ;
            end
        end
        M(i) = getframe ;
    end
    close(f) ;
    drawnow ;
else
    f = figure;
    colormap(settings.colormap) ;
    cmap = colormap ;
    close(f) ;
    for i=1:size(images,3)
        if callbacks.canceled(), close (f); return ; end
        img = images(:,:,i) ;
        img = flipud(img) ; %to match figures
        if strcmp(settings.colorbar,'constant')
            im = real2rgb(img,cmap,clims) ;
        elseif length(settings.colorbar) == 2
            im = real2rgb(img,cmap,settings.colorbar) ;
        else
            im = real2rgb(img,cmap) ;
        end
        M(i) = im2frame(im) ; %#ok<AGROW>
    end
end

[path,name,ext] = fileparts(filename) ; ext = lower(ext(2:end)) ;
if strcmp(ext,'png') || strcmp(ext,'jpeg') || strcmp(ext,'jpg') || strcmp(ext,'tiff')
    for i=1:length(M)
        param = params{i} ;
        if ~isfield(param,'suffix'), param.suffix = i ; end
        filename = fullfile(path,[name '_' num2str(param.suffix) '.' ext]) ;
        imwrite(frame2im(M(i)),filename,ext) ;
        %[imind,cm] = rgb2ind(frame2im(M(i)),256) ;
        %imwrite(imind,cm,filename,'png') ;
    end
else
    try
        saveMovie(M, filename, settings.fps, settings.bg_color) ;
    catch %#ok<CTCH>
        callbacks.status('Invalid file type') ;
    end
end

callbacks.status ('Finished.') ;

end

