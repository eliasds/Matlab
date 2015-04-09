function [h] = scalebar(varargin) 
% SCALEBAR places a graphical reference scale on a map. This function was
% designed as a simpler alternative to the scaleruler function. 
% 
% This function requires Matlab's Mapping Toolbox. 
% 
%% Syntax 
% 
% scalebar
% scalebar('Length',LengthInKilometers)
% scalebar('Location','LocationOnMap')
% scalebar('Orientation','VerticalOrHorizontal')
% scalebar('TextProperty',TextValue)
% scalebar('LineProperty',LineValue)
% h = scalebar(...)
% 
% 
%% Description 
% 
% scalebar places a 100 km graphical reference scale at the lower left-hand
% corner of a map. 
% 
% scalebar('Length',LengthInKilometers) specifies the length of the scalebar. 
% Default length is 100 km. Talk about a scalar value, am I right? 
%
% scalebar('Location','LocationOnMap') specifies location of the scalebar
% on the map. Location can be 
%           'southwest' (lower left) {default} 
%           'northwest' (upper left) 
%           'northeast' (upper right)
%           'southeast' (lower right) 
%
% scalebar('Orientation','VerticalOrHorizontal') specifies a 'vertical' or
% 'horizontal' scalebar. Default value is 'horizontal'. 
%
% scalebar('TextProperty',TextValue) specifies properties of text. 
%
% scalebar('LineProperty',LineValue) specifies properties of the reference
% scale line. 
%
% h = scalebar(...) returns a handle for the scalebar. 
%
% 
%% Examples 
% 
% EXAMPLE 1: 
% figure; usamap('texas')
% states = shaperead('usastatelo.shp','UseGeoCoords',true);
% geoshow(states, 'DisplayType', 'polygon')
% scalebar('length',200,'color','b')
% 
% EXAMPLE 2: (Requires Antarctic Mapping Tools)
% load coast
% antmap
% patchm(lat,long,[.588 .976 .482])
% scalebar('length',1000)
% 
% EXAMPLE 3: (Requires Bedmap2 Toolbox)
% bedmap2 'patchgl'
% bedmap2('patchshelves','oceancolor',[0.0118 0.4431 0.6118])
% bedmap2_zoom 'Mertz Glacier Tongue'
% scarlabel('Mertz Glacier Tongue','fontangle','italic')
% scalebar
%
% 
%% Author Info.  
% 
% This function was created by Chad A. Greene of the University of Texas 
% Institute for Geophysics in 2013. This function was originally designed
% for the Bedmap2 Toolbox for Matlab, but has been slightly updated for 
% inclusion in the Antarctic Mapping Tools package.  Although this function 
% was designed for Antarctic maps, it should work for other maps as well.
% 
% See also scaleruler. 


%% Set defaults:

lngth = 100; % default scalebar length in kilometers
location = 'southwest'; % default location
orientation = 'horizontal'; % default orientation

%% Parse inputs: 

% Check for user-declared location: 
tmp = strncmpi(varargin,'loc',3); 
if any(tmp)
    location = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
    assert(isnumeric(location)==0,'scalebar location must be a string.')
end

% Check for user-declared length (also accept "width" or "scale")
tmp = strncmpi(varargin,'len',3)|strncmpi(varargin,'wid',3)|strcmpi(varargin,'scale'); 
if any(tmp)
    lngth = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
    assert(isscalar(lngth)==1,'Scalebar Length must be a scalar value in kilometers.')
end

 
% Check for user-declared orientation: 
tmp = strncmpi(varargin,'orient',6); 
if any(tmp)
    orientation = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
    assert(isnumeric(orientation)==0,'Scalebar orientation can only be vertical or horizontal.')
end

%% Get size scale: 
        
[lat1,lon1]=minvtran(0,0);
[lat2,lon2]=minvtran(.1,0);
kmpermapunit = 10*distance(lat1,lon1,lat2,lon2,6378.137);

xlim = get(gca,'xlim');
ylim = get(gca,'ylim'); 

switch lower(orientation)
    case 'horizontal'
    switch lower(location)
        case {'southwest','sw'}
            x1 = .05*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1+lngth/kmpermapunit; 
            y1 = .05*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1; 

        case {'southeast','se'}
            x1 = .95*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1-lngth/kmpermapunit; 
            y1 = .05*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1; 

        case {'northwest','nw'}
            x1 = .05*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1+lngth/kmpermapunit; 
            y1 = .95*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1;         

        case {'northeast','ne'}
            x1 = .95*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1-lngth/kmpermapunit; 
            y1 = .95*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1;  
            
        otherwise
            error('Invalid location string for scalebar.')
    end
    
    case 'vertical'
        switch lower(location)
        case {'southwest','sw'}
            x1 = .05*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1;
            y1 = .05*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1 + lngth/kmpermapunit; 

        case {'southeast','se'}
            x1 = .95*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1; 
            y1 = .05*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1 + lngth/kmpermapunit; 

        case {'northwest','nw'}
            x1 = .05*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1; 
            y1 = .95*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1 - lngth/kmpermapunit;        

        case {'northeast','ne'}
            x1 = .95*(xlim(2)-xlim(1))+xlim(1); 
            x2 = x1; 
            y1 = .95*(ylim(2)-ylim(1))+ylim(1); 
            y2 = y1 - lngth/kmpermapunit; 
            
        otherwise
            error('Invalid location string for scalebar.')
        end
end

h(1)=line([x1 x2],[y1 y2],'color','k','linewidth',2);

h(2) = text(mean([x1 x2]),mean([y1 y2]),[num2str(lngth),' km'],...
    'horizontalalignment','center',...
    'verticalalignment','bottom');
    
% This is brute-force, but it says let's try to set everything that can
% be set, be them text properties or line properties:
for k = 1:2:length(varargin)
    try
        set(h(1),varargin{k},varargin{k+1})
    end
    try
        set(h(2),varargin{k},varargin{k+1})
    end
end

% Return the title handle only if it is desired: 
if nargout==0
    clear h; 
end


