function [ h ] = mcolorbar( axis_handle, cm, varargin )
%MCOLORBAR Summary of this function goes here
%   Detailed explanation goes here

if ischar(cm) && strcmp(cm,'clear')
    colormap(axis_handle,[]) ;
    return ;
end

clim = [nan, nan] ;

skip = 0 ;
for i=1:length(varargin)
    if skip, skip = 0 ; continue ; end
    if strcmp(varargin{i},'clear')
        option = 'clear' ;
    elseif strcmp(varargin{i},'clim') && i + 1 <= length(varargin)
        clim = varargin{i+1} ;
        skip = 1 ;
    end
end

fig = ancestor(axis_handle,'figure') ;
cmap = colormap (fig) ;

cmap_i = reshape(round(cmap' * 255), 1, length(cmap)*3) ;
cm_i = reshape(round(cm' * 255), 1, length(cm)*3) ;
colormap_index = strfind(cmap_i, cm_i) ;
if isempty(colormap_index)
    if exist('option','var') && strcmp(option,'clear'), cmap = [] ; end
    colormap_index = length(cmap) + 1 ;
    cmap = [cmap; cm] ;
    colormap(fig, cmap) ;
else
    colormap_index = (colormap_index + 2) / 3 ;
end

if length(cmap) > 256 && strcmp(get(gcf,'Renderer'),'painters')
    error ('Error: Colormap can only handle 256 colors when using painters renderer.') ;
end

h = colorbar('peer',axis_handle) ;

dataobjects = findobj(axis_handle, '-property', 'CData') ;
cdata_min = 0 ; cdata_max = 1 ; cdata = [] ;
for i=1:length(dataobjects)
    cdata = get(dataobjects(i),'CData') ;
    if isempty(cdata) cdata = 1 ; end
    cdata_min = min(cdata(~isinf(cdata(:)))) ;
    cdata_max = max(cdata(~isinf(cdata(:)))) ;
    if isempty(cdata_min) || isempty(cdata_max) || cdata_min == cdata_max
        cdata_min = 0 ;
        cdata_max = 1 ;
    end
    cdata(isinf(cdata(:)) & cdata(:) > 0) = cdata_max ;
    cdata(isinf(cdata(:)) & cdata(:) < 0) = cdata_min ;
    if ~isnan(clim(1)), cdata_min = clim(1) ; end
    if ~isnan(clim(2)), cdata_max = clim(2) ; end
    cdata = colormap_index + round((cdata - cdata_min)/(cdata_max - cdata_min) * (length(cm) - 1)) ;
    cdata(isnan(cdata(:))) = min(cdata(:)) ;
    cdata(isinf(cdata(:))) = max(cdata(:)) ;
    set(dataobjects(i),'CData',cdata,'CDataMapping','direct') ;
end
scaleFn = @(x)(x-colormap_index)/(length(cm)-1)*(cdata_max - cdata_min)+cdata_min ;

hhAxes = handle(h) ;
hProp = findprop(hhAxes,'YLim') ;
hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @(~,~)set(h, 'YLim', [colormap_index, colormap_index - 1 + length(cm)])) ;
setappdata(h,'YLimListener',hListener) ;
%Update colorbar ticks automatically
if ~isempty(cdata)
    hProp = findprop(hhAxes,'YTick') ;
    hListener = handle.listener(hhAxes, hProp, 'PropertyPostSet', @(hProp,eventData)formatTickLabels(hProp,eventData,scaleFn)) ;
    setappdata(h,'YTickListener',hListener) ;
end

end

function formatTickLabels(~,eventData,scaleFn)
   hAxes = eventData.AffectedObject;
   tickValues = get(hAxes,'YTick');
 
   tickValues = scaleFn (tickValues) ;
   magnitude = round(log10(abs(tickValues))) ;
   magnitude(isinf(magnitude)) = 0 ;
   if min(magnitude) >= 3 || max(magnitude) < -1
       expformat = 'e%.0f' ;
       tickValues = tickValues .* 10.^(-1*round(log10(abs(tickValues)))) ;
   else
       expformat = '' ;
   end
   
   if sum(isnan(tickValues)) > 0 || max(tickValues) == min(tickValues)
       tickValues = linspace(0,1,length(tickValues)) ;
       expformat = '' ;
   end;
   
   %newLabels = arrayfun(@(value)(sprintf('%.1fV',value)), tickValues, 'UniformOutput',false);
   digits = 0;
   labelsOverlap = true;
   while labelsOverlap
      % Add another decimal digit to the format until the labels become distinct
      format = [sprintf('%%.%df',digits) expformat];
      if isempty(expformat)
          newLabels = arrayfun(@(value,mag)(sprintf(format,value)), tickValues, magnitude, 'UniformOutput',false);
      else
          newLabels = arrayfun(@(value,mag)(sprintf(format,value,mag)), tickValues, magnitude, 'UniformOutput',false);
      end
      labelsOverlap = (length(newLabels) > length(unique(newLabels)));
      % prevent endless loop if the tick values themselves are non-unique
      if labelsOverlap && max(diff(tickValues))< 16*eps, break; end
      digits = digits + 1;
   end
   set(hAxes, 'YTickLabel', newLabels);
end