function [ x_out, y_out, y_err ] = smooth2( x, y, options )
%SMOOTH2 Resample data by taking local linear fits 
%   Sampling of x on output is decided by: 
%   a minimum spacing is defined, if the input points are spaced farther
%   than that those spacings are used

if ~exist ('options', 'var')
    options = struct ('N', 40, 'fit_order', 2, 'fit_range', 2, ...
                      'mapX', @log10, 'unmapX', @(x)10.^x, ...
                      'mapY', @log10, 'unmapY', @(x)10.^x) ;
end

if isfield(options, 'mapX'), x = options.mapX(x) ; end
if isfield(options, 'mapY'), y = options.mapY(y) ; end
y = y(~isnan(x)) ; x = x(~isnan(x)) ;
x = x(~isnan(y)) ; y = y(~isnan(y)) ;
y = y(~isinf(x)) ; x = x(~isinf(x)) ;

if isfield(options,'x')
    if isfield(options, 'mapX')
        x_out = options.mapX(options.x) ;
    else
        x_out = options.x ;
    end
else
    x_min = min(x) ;
    x_max = max(x) ;
    dx = (x_max - x_min) / options.N ;
    x_out = x_min:dx:x_max ;
end

y_out = zeros(size(x_out)) ;
y_err = zeros(size(x_out)) ;
for i=1:length(x_out)
    if i==1
        filt = (x <= (x_out(i) + (x_out(i+1) - x_out(i))*options.fit_range)) ;
    elseif i==length(x_out)
        filt = (x >= (x_out(i) - (x_out(i) - x_out(i-1))*options.fit_range)) ;
    else
        filt = (x >= (x_out(i) - (x_out(i) - x_out(i-1))*options.fit_range)) & (x <= (x_out(i) + (x_out(i+1) - x_out(i))*options.fit_range)) ;
    end
    filt = filt & ~isnan(x) & ~isnan(y) & ~isinf(y) ;
    x_vals = x(filt) ;
    y_vals = y(filt) ;
    if length(x_vals) > 2 * options.fit_order
        [p, s] = polyfit(x_vals,y_vals, options.fit_order) ;
        [y_out(i), y_err(i)] = polyval(p,x_out(i), s) ;
    elseif length(x_vals) > 1
        try
            warning('error', 'MATLAB:polyval:ZeroDOF'); %#ok<CTPCT>
            [p, s] = polyfit(x_vals,y_vals,1) ;
            [y_out(i), y_err(i)] = polyval(p,x_out(i), s) ;
        catch
            y_out(i) = mean(y_vals) ;
            y_err(i) = std(y_vals) ;
        end
    elseif length(x_vals) == 1
        x_out(i) = x_vals ;
        y_out(i) = y_vals ;
        y_err(i) = inf ;
    else
        y_out(i) = nan ;
        y_err(i) = nan ;
    end
end

if ~isfield(options,'x')
    x_out = x_out(~isnan(y_out)) ;
    y_out = y_out(~isnan(y_out)) ;
    y_err = y_err(~isnan(y_out)) ;
end

if isfield(options,'unmapY')
    y_err = [options.unmapY(y_out - y_err); options.unmapY(y_out + y_err)] ;
else
    y_err = [y_out + y_err; y_out - y_err] ;
end

if isfield(options,'unmapX'), x_out = options.unmapX(x_out) ; end
if isfield(options,'unmapY'), y_out = options.unmapY(y_out) ; end

end

