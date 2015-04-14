function [ E, results, imgs ] = visualizeTF( imgs, params, settings, callbacks )
%{
   This is a special function that visualizes the transfer function. It
   will export the function using `tovideo` so any options from that are
   possible.

   Additional options that can be used are:
    sweep - name of the variable to use as the sweep
    sweep_size - the height of the sweep bar, in pixels or percent
    sweep_on - value to set the sweep bar on (between 0 and 1)
    sweep_off - value to set the sweep bar off (between 0 and 1)
    sweep_pos - 'top' or 'bottom'
%}
n = size(imgs,1) ;
m = size(imgs,3) ;

tf_options = struct('no_dc', 1) ;
if isfield(settings,'tf_subsample'), tf_options.subsample = settings.tf_subsample ; end
tf_re = zeros(n,n,m) ; tf_im = zeros(n,n,m) ; intensity_scaling = zeros(1, m) ;
for i=1:m
    [tf_re(:,:,i), tf_im(:,:,i), ~, intensity_scaling(i)] = ...
                                                calculateTF (n, ...
                                                params{i}.wavelength / params{i}.pixel_size, ...
                                                params{i}.pupil, ...
                                                params{i}.illumination, ...
                                                tf_options) ;
end
tf_re = real(tf_re) ;
tf_im = real(tf_im) ;
if ~isfield(settings,'component'), settings.component = 'all' ; end
switch (settings.component)
    case 'real'
        imgs = real(tf_re) ;
    case 'imag'
        imgs = real(tf_im) ;
    case 'both'
        imgs = cat(3, real(tf_re), real(tf_im)) ;
        params = [params, params] ;
        for i=1:m
            p = params{i} ;
            if ~isfield(p,'suffix'), p.suffix = '' ;
            else p.suffix = ['_' p.suffix] ; end
            p.suffix = ['real' p.suffix] ;
            params{i} = p ;
        end
        for i=(1:m)+m
            p = params{i} ;
            if ~isfield(p,'suffix'), p.suffix = '' ;
            else p.suffix = ['_' p.suffix] ; end
            p.suffix = ['imag' p.suffix] ;
            params{i} = p ;
        end
    case 'all'
        imgs = zeros(size(tf_re,1)*2, size(tf_re,2)*2, size(tf_re,3)) ;
        for i=1:m
            imgs(:,:,i) = [tf_re(:,:,i), tf_im(:,:,i); ...
                           max(tf_re,[],3), max(tf_im,[],3)] ;
        end
        if isfield(settings,'sweep') && isfield(params{1},settings.sweep)
            sweep_param = arrayfun(@(x)x{1}.(settings.sweep),params) ;
            sweep_param = sweep_param - min(sweep_param(:)) ; sweep_param = sweep_param / max(sweep_param) ;
            imgs = imgs - min(imgs(:)) ; imgs = imgs / max(imgs(:)) ;
            if ~isfield(settings, 'sweep_size'), settings.sweep_size = 0.05 ; end
            if settings.sweep_size < 1, settings.sweep_size = ceil(size(imgs,3) * settings.sweep_size) ; end
            if ~isfield(settings, 'sweep_on'), settings.sweep_on = 1 ; end
            if ~isfield(settings, 'sweep_off'), settings.sweep_off = 0 ; end
            if ~isfield(settings, 'sweep_pos'), settings.sweep_pos = 'bottom' ; end
            switch settings.sweep_pos
                case 'top'
                    imgs = cat(1,imgs,zeros(settings.sweep_size,size(imgs,2),size(imgs,3))) ;
                case 'bottom'
                    imgs = cat(1,zeros(settings.sweep_size,size(imgs,2),size(imgs,3)),imgs) ;
                otherwise
                    error('Invalid `sweep_pos` (%s)', settings.sweep_pos) ;
            end
            x = linspace(0, 1, size(imgs,2)) ;
            for i=1:m
                sweep_vals = repmat(x > sweep_param(i), [settings.sweep_size,1,1]) ;
                set_val = sweep_vals * settings.sweep_on ;
                set_val(~sweep_vals) = settings.sweep_off ;
                switch settings.sweep_pos
                    case 'top'
                        imgs(end-(1:settings.sweep_size)+1,:,i) = set_val ;
                    case 'bottom'
                        imgs((1:settings.sweep_size),:,i) = set_val ;
                end
            end
        end
    otherwise
        error('component can be ''real'', ''imag'', or ''all''') ;
end

cd ../tovideo ;
[ E, results ] = exportToVideo( imgs, params, settings, callbacks ) ;
cd ../ppr

end