function [ ] = visualizeTFfit( x, y, images, tf_re, tf_im, E_fft, Etrue )
%the dashed planes are the true values if they show up
    SCALE = 0.02 ;
    REAL   = [1,0,0] ;
    IMAG  = [0,0,1] ;
    
    if size(E_fft,3) == 2
        E_fft = cat(3, E_fft, zeros(size(E_fft,1), size(E_fft,2))) ;
    end
    
    rec_set = {} ;
    true_set = {} ;

    images_fft = fftshift(fftshift(fft2(images),1),2) ;
    
    tfx = squeeze(tf_re(x,y,:)) ;
    tfy = squeeze(tf_im(x,y,:)) ;
    z_re = squeeze(real(images_fft(x,y,:))) ;
    z_im = squeeze(imag(images_fft(x,y,:))) ;
    xy_lim = max(abs([tfx;tfy])) ; xy_lim = [-xy_lim; xy_lim] ;
    z_lim = max(abs([z_re;z_im])) ; z_lim = [-z_lim; z_lim] ;
    if diff(z_lim) == 0, z_lim = [-1, 1] ; end
    

    

    fig = figure('name', 'Visualize Fit');
    plot3(0,0,0);
    hold on ;
    light ('Position',[0,xy_lim(1),z_lim(2)]);
    lighting phong;
    shading interp ;
    xlim(xy_lim); ylim(xy_lim) ; zlim(z_lim);

    scale = SCALE * [xy_lim(2), xy_lim(2), z_lim(2)] ;
    
    plot_3d (tfx,tfy,z_re,scale,REAL) ;
    plot_3d (tfx,tfy,z_im,scale,IMAG) ;
    plot_3d (0,0,0,scale*0.5,[0,0,0]) ;
    labels = cellstr( num2str((1:length(tfx))') );
    text(tfx,tfy,repmat(z_lim(1),1,length(tfx)), labels, 'VerticalAlignment','bottom', ...
                                 'HorizontalAlignment','right', 'FontWeight', 'bold')
    

    [xx,yy] = meshgrid(linspace(xy_lim(1), xy_lim(2), 2)) ;
    zz_re = real(sum(repmat(squeeze(E_fft(x,y,:))',length(xx(:)),1).*[xx(:), yy(:), ones(size(xx(:)))],2)) ;
    zz_im = -imag(sum(repmat(squeeze(E_fft(x,y,:))',length(xx(:)),1).*[xx(:), yy(:), ones(size(xx(:)))],2)) ;
    zz_re = reshape(zz_re, size(xx)) ; zz_im = reshape(zz_im, size(xx)) ;
    
    rec_set{1} = surf(xx,yy,zz_re, repmat(reshape(REAL,1,1,3), [length(xx), length(xx), 1]), 'EdgeColor', REAL, 'FaceAlpha', 0.3) ;
    rec_set{2} = surf(xx,yy,zz_im, repmat(reshape(IMAG,1,1,3), [length(xx), length(xx), 1]), 'EdgeColor', IMAG, 'FaceAlpha', 0.3) ;
    
    if exist('Etrue','var')
        E_fft_re_true = fftshift(fft2(real(Etrue))) ;
        E_fft_im_true = fftshift(fft2(imag(Etrue))) ;
        [xx2,yy2] = meshgrid(linspace(xy_lim(1), xy_lim(2), 7)) ;
        zz_re_true = real(sum(repmat([E_fft_re_true(x,y), E_fft_im_true(x,y)],length(xx2(:)),1).*[xx2(:), yy2(:)],2)) ;
        zz_im_true = imag(sum(repmat([E_fft_re_true(x,y), E_fft_im_true(x,y)],length(xx2(:)),1).*[xx2(:), yy2(:)],2)) ;
        zz_re_true = reshape(zz_re_true, size(xx2)) ; zz_im_true = reshape(zz_im_true, size(xx2)) ;

        true_set{1} = surf(xx2,yy2,zz_re_true, repmat(reshape(REAL,1,1,3), [length(xx2), length(xx2), 1]), 'EdgeColor', REAL, 'FaceAlpha', 0.2) ;
        true_set{2} = surf(xx2,yy2,zz_im_true, repmat(reshape(IMAG,1,1,3), [length(xx2), length(xx2), 1]), 'EdgeColor', IMAG, 'FaceAlpha', 0.2) ;
    end

    colormap ([REAL;IMAG]);
    lcolorbar ({'Real', 'Imaginary'}) ;
    grid on ;
    xlabel ('K_{Re}') ;
    ylabel ('K_{Im}') ;
    zlabel ('F\{I\}') ;
    title (sprintf('%d, %d', x, y)) ;

    guidata(fig, {true_set, rec_set}) ;


    oldkeyhook = get(fig, 'KeyPressFcn');
    newkeyhook = oldkeyhook;
    newkeyhook{1} = @toggleVisibility;

    h = rotate3d(fig);
    set(h, 'Enable', 'on');

    hManager = uigetmodemanager(fig);
    set(hManager.WindowListenerHandles,'Enable','off'); % zap the listeners
    % with the listners turned off we can put in our own hook
    set(fig, 'KeyPressFcn', newkeyhook );

end

function toggleVisibility (fig, event)
    if strcmp(event.Key, 'escape')
        close (fig) ;
        return ;
    elseif isempty(regexp(event.Key, '^([0-9]|space)$', 'once'))
        return ;
    end
    sets = guidata(fig) ;
    if isempty(sets{1}), return ; end
    true_sets = zeros(1,length(sets)) ;
    for i=1:length(sets)
        st = sets{i} ;
        true_sets(i) = strcmp(get(st{1},'Visible'),'on') ;
        for j=1:length(st)
            set(st{j},'Visible','off') ;
        end
    end
    if ~isempty(regexp(event.Key, '^\d$','match')) && str2double(event.Key) <= length(sets)
        st = str2double(event.Key) ;
    else
        if sum(true_sets) == length(sets)
            st = 1 ; %toggle first set
        else
            st = find(true_sets) + 1 ;
        end
    end
    if st == (length(sets) + 1)
        for i=1:length(sets)
            st = sets{i} ;
            for j=1:length(st)
                set(st{j},'Visible','on') ;
            end
        end
    else
        st = sets{st} ;
        for j=1:length(st)
            set(st{j},'Visible','on') ;
        end
    end
end

function plot_3d (x,y,z,scale,color)

    [X2, Y2, Z2] = sphere() ;
    col = repmat(reshape(color,1,1,3), [length(X2), length(X2), 1]) ;
    zl = zlim ;

    for i=1:length(x)
        surf(X2*scale(1) + x(i), Y2*scale(2) + y(i), Z2*scale(3) + z(i), col, ...
         'EdgeColor', 'none', 'FaceAlpha', 1) ;
        plot3 ([1,1]*x(i), [1,1]*y(i), [z(i),zl(1)], '-', 'Color', color) ;
        [cx,cy] = circle(x(i), y(i), scale(1),32) ;
        plot3 (cx,cy,ones(size(cx))*zl(1), '-', 'Color', color) ;
    end

end
function [cx, cy] = circle(center_x, center_y, r, n)
    ang = linspace(0, 2*pi, n) ;
    cx = r * cos(ang) + center_x ;
    cy = r * sin(ang) + center_y ;
end
