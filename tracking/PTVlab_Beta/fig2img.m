function fig2img(dpi,flagScreenSize)
% saveFig: saves the current figure to a file
%
% Inputs:
%   res: dpi resolution to save image (300 dpi - default)
%   flagScreenSize: figure size to use. 0 = use default figure size, 1 = 
%   use actual size of figure (0 is default)
%
% Usage:
%
%   This function only saves the CURRENT FIGURE to file. The current figure
%   is the last figure that you clicked or generated. If you are not sure
%   which figure is current, simply click on the figure and then run
%   fig2img.
%   
%   1. Save current figure using defaults (300 dpi, png file, default figure size).
%       >> fig2file()
%   2. Save current figure as image with 600 dpi using actual size of figure.
%       >> fig2file(600,1)
%   3. Save current figure as a image with 300 dpi using default fig size.
%       >> fig2file(300,1)
%
% Note: See documentation on 'print' for other types of image formats and other info.

if nargin<2; flagScreenSize=false; end
if nargin<1; dpi='-r300'; end
if isnumeric(dpi)
    dpi=['-r' num2str(dpi)];
else
    if isempty(findstr('-r',dpi)); dpi=['-r' dpi]; end
end


[fn fp fi]=uiputfile( ...
  {'*.png', 'PNG (*.png)';...
  '*.jpeg','JPEG (*.jpeg)';...
  '*.bmp','Bitmap (*.bmp)';...
  '*.tif','TIFF (*.tif)';...
  '*.eps','EPS color (*.eps)';...
  '*.pdf','PDF (*.pdf)'},...
  'Save Figure As Image'); %get file name and path
if ~fi; return; end %Check - must select a file

[a b ext]=fileparts(fn); %get extension
clear a b;

%determine image file format to use
switch ext
    case {'.png','.jpeg','.bmp','.eps','.pdf'}
        format=['-d' ext(2:end)];
    case '.tif'
        format=['-d' ext(2:end) 'f'];
end

%determine what size to save figure
if flagScreenSize; 
    ppm=get(gcf,'PaperPositionMode');
    set(gcf,'PaperPositionMode','auto')
end

%save figure
print(format,dpi,fullfile(fp,fn)) %print to file

%reset screen settings if needed
if flagScreenSize; set(gcf,'PaperPositionMode',ppm); end % set it back
end