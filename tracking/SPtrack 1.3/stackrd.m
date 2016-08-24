

function varargout = stackrd(varargin)

if isempty(varargin)
    % if no image specifdied, open a dialog to choose a file, then call
    % readstack to load the 3D image.
    [fileName, pathName] = uigetfile( ...
       {'*.gif;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp;*.png', ...
            'All Image Files (*.bmp, *.jpg, *.tif, *.png)'; ...
        '*.tif;*.tiff',             'Tagged Image File Format (*.tif, *.tiff)'; ...
        '*.png',                    'Portable Network Graphics (*.png)'; ...
        '*.bmp',                    'Windows Bitmap (*.bmp)'; ...
        '*.*',                      'All Files (*.*)'}, ...
        'Choose a stack, or the first slice of a series :');

    if isequal(fileName,0) || isequal(pathName,0)
        guidata(hObject, handles);
        return;
    end

    handles.img = readstack(fullfile(pathName, fileName));
    handles.lastPath = pathName;
    imgName = fileName;
else
    % TODO : add a control on entry
    handles.img = varargin{1};
    imgName = '';    
end
