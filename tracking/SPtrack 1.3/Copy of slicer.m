function varargout = slicer(varargin)
%SLICER interactive visualization of 3D images
%
%   slicer(IMG), where IMG is a preloaded M*N*P matrix, opens slicer using
%   User can change current slice with the slider to the left, X and Y
%   position with the two corresponding sliders, and change the zoom.
%
%   Index of current slice is given under the slider, and cursor position
%   is indicated when user clics on image.
%
%   slicer  without argument opens a dialog to read a file (either set of
%   slices or bundle-stack).
%
%   slicer should work with any kind of images (binary, gray scale and
%   color)
%
%   slicer(IMG, SLICE) : directly shows the slice given as parameter.
%
%   slicer(IMG, POS) : set the initital position to POS. POS is given as [X
%   Y SLICE].
%
%   slicer(IMG, POS, ZOOM) : specifies the initial zoom. if no zoom is
%   specified, SLCIER automatically find the best zoom for image.
%
%   requires :
%   readstack
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 21/11/2003 
%

%   HISTORY
%   28/06/2004 : allows small images
%   15/10/2004 : add slider for positioning, zoom, and possibility to load
%       images
%   18/10/2004 : correct bug for input image type (was set to uint8), and
%       in positioning. Also add remembering of last opened path.
%   19/10/2004 : correct bugs in display (view window too large)
%   26/10/2004 : correct bug for color images (were seen as gray-scale)
%   25/03/2005 : add size of image in title, and starting options
%   29/03/2005 : automatically find best zoom when starting, if no zoom is
%       specified. Add doc.
%   21/02/2006 : adapt to windows file format

% Edit the above text to modify the response to help slicer

% Last Modified by GUIDE v2.5 26-Aug-2007 04:45:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @slicer_OpeningFcn, ...
                   'gui_OutputFcn',  @slicer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% ===========================================================
% intialization functions

% --- Executes just before slicer is made visible.
function slicer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to slicer (see VARARGIN)

% Choose default command line output for slicer
handles.output = hObject;

% default values
handles.view = [512 512];
handles.lastPath = pwd;
handles.pos = [1 1 1];
handles.zoom = 1;
handles.zoomMin = 1/64;
handles.zoomMax = 64;
handles.baseTitle = 'Slicer - %s [%dx%dx%d] - %d:%d';

view = handles.view;

% check inputs
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


% find dimensions of image, without the color channel
dim = size(handles.img);
handles.color=false;
if length(dim)>3
    dim = dim([1 2 4]);
    handles.color=true;
end

% get initial position of slicer
if length(varargin)>1
    pos = varargin{2};
    if length(pos)==3
        handles.pos = reshape(pos,[1 3]);
    else
        handles.pos = [1 1 pos(1)];
    end
end

% get initial zoom of slicer
if length(varargin)>2        
    zoom = varargin{3};
    if zoom>handles.zoomMin && zoom<handles.zoomMax
        handles.zoom = zoom;
    else
        warning('slicer: bad value for parameter zoom');
    end
else
    zoom = min(view(1)/dim(1), view(2)/dim(2));
    % round zoom to the closest lower power of 2.
    zoom = power(2, fix(log2(zoom)));
    handles.zoom = zoom;
end

zoom = handles.zoom;



% assert the current position is valid
xmin = 1;
%xmax = dim(2)-view(2)+1;
xmax = ceil(dim(2)-view(2)/zoom+1);
ymin = 1;
%ymax = dim(1)-view(1)+1;
ymax = ceil(dim(1)-view(1)/zoom+1);
zmax = dim(3);
handles.pos = max(min(handles.pos, [ymax xmax zmax]), [ymin xmin 1]);
pos = handles.pos;
zslice = handles.pos(3);


% set title of the figure, 
% containing name of argument if possible, 
% and  current zoom factor.
if isempty(imgName)
    imgName = 'unknown image';
end
set(handles.mainFrame, 'Name', sprintf(handles.baseTitle, imgName, ...
    dim(1), dim(2), dim(3), max(1, zoom), max(1, 1/zoom)));


% create an empty image with the appropriate size and data,
% and init to the specified slice
if handles.color
    h_img = imshow(handles.img(:,:,:, zslice));
else
    h_img = imshow(handles.img(:,:, zslice));
end
set(h_img, 'XData', [1 dim(2)]);
set(h_img, 'YData', [1 dim(1)]);
%set(handles.imageDisplay, 'xlim', [.5 view(2)+.5]);
%set(handles.imageDisplay, 'ylim', [.5 view(1)+.5]);
set(handles.imageDisplay, 'xlim', [pos(2)-.5 pos(2)-1+view(2)/zoom+.5]);
set(handles.imageDisplay, 'ylim', [pos(1)-.5 pos(1)-1+view(1)/zoom+.5]);
if ischar(handles.img)
    colormap(gray);
end

% set up the gui options of image
hold on;
set(h_img, 'ButtonDownFcn', ...
    'slicer(''imageDisplay_ButtonDownFcn'',gcbo,[],guidata(gcbo))');

% update control for changing slice
hd = handles.moveZSlider;
set(hd, 'min', 1);
set(hd, 'max', zmax);
set(hd, 'value', zslice);
set(hd, 'sliderstep', [1/(zmax-1) 5/(zmax-1)]);

set(handles.sliceNumberText, 'String', num2str(zslice));

% compute limit for x slider bar
hd = handles.moveXSlider;
set(hd, 'min', xmin);
set(hd, 'max', xmax);
set(hd, 'value', pos(2));
if xmax>1
    set(hd, 'sliderstep', [1/(xmax-1) 20/(xmax-1)])
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end



% compute limit for y slider bar
hd = handles.moveYSlider;
set(hd, 'min', ymin);
set(hd, 'max', ymax);
set(hd, 'value', ymax-pos(1)+1);
if ymax>1
    set(hd, 'sliderstep', [1/(ymax-1) 20/(ymax-1)]);
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end

% update userdata
handles.dim = dim;
handles.view = view;
handles.h_img = h_img;
handles.imgName = imgName;


%handles.img = img;
%handles.h_img = h_img;

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = slicer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function moveZSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moveZSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% ===========================================================
% general purpose functions


% ------------------------------------------------
function setSlice(handles)
% change the current slice.
% slice number is the third value of field POS in handles.


% get slice
slice = handles.pos(3);

% change inner data of image
if handles.color
    set(handles.h_img, 'CData', handles.img(:,:,:,slice));
else
    set(handles.h_img, 'CData', handles.img(:,:,slice));
end

% update gui information for slider and textbox
set(handles.moveZSlider, 'Value', slice);
set(handles.sliceNumberText, 'String', num2str(slice));

% update gui data
guidata(handles.mainFrame, handles);


% ------------------------------------------------
function setZoom(handles)
% handles    structure with handles and user data (see GUIDATA)

zoom = handles.zoom;
if zoom>handles.zoomMax || zoom<handles.zoomMin
    disp('zoom value out of bounds');
    return;
end

% compute center of image
ci(1) = mean(get(handles.imageDisplay, 'YLim'));
ci(2) = mean(get(handles.imageDisplay, 'XLim'));

% compute new position of image
view = handles.view;
dim = handles.dim;
handles.pos(1) = max(min(ci(1)-view(1)/2/zoom, dim(1)-view(1)/zoom+1), 1);
handles.pos(2) = max(min(ci(2)-view(2)/2/zoom, dim(2)-view(2)/zoom+1), 1);

% update title of the frame
%title = sprintf(handles.baseTitle, handles.imgName, ...
%    max(1, zoom), max(1, 1/zoom));
title = sprintf(handles.baseTitle, handles.imgName, ...
    dim(1), dim(2), dim(3), max(1, zoom), max(1, 1/zoom));
set(handles.mainFrame, 'Name', title);


% compute limit for x slider bar
hd = handles.moveXSlider;
xmin = 1;
xmax = ceil(handles.dim(2)-handles.view(2)/zoom+1);
set(hd, 'Min', xmin);
set(hd, 'Max', xmax);
if xmax>1
    set(hd, 'Sliderstep', [1/(xmax-1) 20/(xmax-1)]);
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'Sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end


% compute limit for y slider bar
hd = handles.moveYSlider;
ymin = 1;
ymax = ceil(handles.dim(1)-handles.view(1)/zoom+1);
set(hd, 'Min', ymin);
set(hd, 'Max', ymax);
if ymax>1
    set(hd, 'Sliderstep', [1/(ymax-1) 20/(ymax-1)]);
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'Sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end

% update gui data
%guidata(handles.mainFrame, handles);

setPosition(handles);



% ------------------------------------------------
function setPosition(handles)
% change the position of top-left corner of view.
%   - update axis limits
%   - update X- and Y-slicers

pos     = handles.pos;
view    = handles.view;
zoom    = handles.zoom;

set(handles.imageDisplay, 'xlim', [pos(2)-.5 pos(2)-1+view(2)/zoom+.5]);
set(handles.imageDisplay, 'ylim', [pos(1)-.5 pos(1)-1+view(1)/zoom+.5]);

set(handles.moveXSlider, 'Value', pos(2));
ymax = get(handles.moveYSlider, 'Max');
set(handles.moveYSlider, 'Value', ymax-pos(1)+1);

guidata(handles.mainFrame, handles);


% ===========================================================
% callback function for GUI components


% ----------------------------------------------------
% callback functions for sliders



% --- Executes on slider movement.
function moveZSlider_Callback(hObject, eventdata, handles)
% hObject    handle to moveZSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute new value from slicer position, and update textString
zslice = round(get(hObject, 'Value'));
zslice = max(get(hObject, 'Min'), min(get(hObject, 'Max'), zslice));

handles.pos(3) = zslice;
setSlice(handles);



% --- Executes on slider movement.
function moveXSlider_Callback(hObject, eventdata, handles)
% hObject    handle to moveXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute value inside of bounds
value = round(get(hObject, 'Value'));
value = min(max(get(hObject, 'Min'), value), get(hObject, 'Max'));

% update GUI
handles.pos(2) = value;
setPosition(handles);



% --- Executes during object creation, after setting all properties.
function moveXSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moveXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function moveYSlider_Callback(hObject, eventdata, handles)
% hObject    handle to moveYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute value inside of bounds
value = round(get(hObject, 'Max')-get(hObject, 'Value')+1);
%value = round(get(hObject, 'Value')+1);
value = min(max(get(hObject, 'Min'), value), get(hObject, 'Max'));

% update GUI
handles.pos(1) = value;
setPosition(handles);


% --- Executes during object creation, after setting all properties.
function moveYSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moveYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% ----------------------------------------------------
% callback functions for text areas


% --- Executes during object creation, after setting all properties.
function sliceNumberText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes when a new text is typed in sliceNumberText
function sliceNumberText_Callback(hObject, eventdata, handles)
% hObject    handle to sliceNumberText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceNumberText as text
%        str2double(get(hObject,'String')) returns contents of sliceNumberText as a double

% get entered value for z-slice
zslice = str2double(get(hObject, 'String'));

% in case of wrong edit, set the string to current value of zslice
if isnan(zslice)
    zslice = handles.pos(3);
end

% compute slice number, inside of image bounds
zslice = min(max(1, round(zslice)), handles.dim(3));

% update text and slider info
handles.pos(3) = zslice;
setSlice(handles);



% ----------------------------------------------------
% callback functions for buttons


% --- Executes on button press in zoomInButton.
function zoomInButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%zoom = getfield(get(handles.mainFrame, 'userdata'), 'zoom');
handles.zoom = handles.zoom*2;
setZoom(handles);


% --- Executes on button press in zoomOutButton.
function zoomOutButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%zoom = getfield(get(handles.mainFrame, 'userdata'), 'zoom');
handles.zoom = handles.zoom/2;
setZoom(handles);


% --- Executes on button press in zoomOneButton.
function zoomOneButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.zoom=1;
setZoom(handles);

% --- Executes on button press in zoomBestButton.
function zoomBestButton_Callback(hObject, eventdata, handles)
% hObject    handle to zoomBestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get size of image and of view
dim = size(handles.img);
view = handles.view;

% compute best zoom to display entire image
handles.zoom = min(view(1)/dim(1), view(2)/dim(2));

% update properties
setZoom(handles);


% ===========================================================
% callback function for Menu components


% --------------------------------------------------------------------
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nothing to do ....

% --------------------------------------------------------------------
function openItem_Callback(hObject, eventdata, handles)
% hObject    handle to openItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tmpPath = pwd;
cd(handles.lastPath);

[filename, pathname] = uigetfile( ...
       {'*.gif;*.jpg;*.jpeg;*.tif;*.tiff;*.bmp', ...
            'All Image Files (*.bmp, *.jpg, *.jpeg, *.tif, *.tiff)'; ...
        '*.tif;*.tiff',             'All TIF Files (*.tif, *.tiff)'; ...
        '*.bmp',                    'All BMP Files (*.bmp)'; ...
        '*.*',                      'All Files (*.*)'}, ...
        'Choose a stack or the first slice of a serie :');
cd(tmpPath);

if isequal(filename,0) || isequal(pathname,0)
    return;
end

handles.img = readstack(fullfile(pathname, filename));
dim = size(handles.img);
handles.color = false;
if length(dim)>3
    dim = dim([1 2 4]);
    handles.color = true;
end
view = handles.view;

% reset current axis
cla(handles.imageDisplay);

% create an empty image with the appropriate size and data
if handles.color
    h_img = imshow(handles.img(:,:,:, 1));
else
    h_img = imshow(handles.img(:,:, 1));
end
set(h_img, 'XData', [1 dim(2)]);
set(h_img, 'YData', [1 dim(1)]);

set(handles.imageDisplay, 'xlim', [.5 view(2)+.5]);
set(handles.imageDisplay, 'ylim', [.5 view(1)+.5]);
if ischar(handles.img)
    colormap(gray);
end




% set up the gui options of image
hold on;
set(h_img, 'ButtonDownFcn', ...
    'slicer(''imageDisplay_ButtonDownFcn'',gcbo,[],guidata(gcbo))');

% update control for changing slice
hd = handles.moveZSlider;
zmax = dim(3);
zslice = 1;
set(hd, 'min', 1);
set(hd, 'max', zmax);
set(hd, 'value', zslice);
set(hd, 'sliderstep', [1/(zmax-1) 5/(zmax-1)]);

set(handles.sliceNumberText, 'String', num2str(zslice));

% compute limit for x slider bar
hd = handles.moveXSlider;
xmin = 1;
xmax = dim(2)-view(2)+1;
set(hd, 'min', xmin);
set(hd, 'max', xmax);
set(hd, 'value', 1);
if xmax>1
    set(hd, 'sliderstep', [1/(xmax-1) 20/(xmax-1)])
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end


% compute limit for y slider bar
hd = handles.moveYSlider;
ymin = 1;
ymax = dim(1)-view(1)+1;
set(hd, 'min', ymin);
set(hd, 'max', ymax);
set(hd, 'value', ymax);
if ymax>1
    set(hd, 'sliderstep', [1/(ymax-1) 20/(ymax-1)]);
    set(hd, 'Enable', 'on');
    set(hd, 'Visible', 'on');
else
    set(hd, 'sliderstep', [1 1]);
    set(hd, 'Visible', 'off');
end


%handles.img = img;
handles.dim = dim;
handles.zoom = 1;
handles.imgName = filename;
handles.pos = [1 1 1];
handles.h_img = h_img;
handles.lastPath = pathname;

setSlice(handles);
setZoom(handles);

% --------------------------------------------------------------------
function quitItem_Callback(hObject, eventdata, handles)
% hObject    handle to quitItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFrame);

% --------------------------------------------------------------------
function stackItem_Callback(hObject, eventdata, handles)
% hObject    handle to stackItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function aboutItem_Callback(hObject, eventdata, handles)
% hObject    handle to aboutItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function helpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nothing to do ....



% --------------------------------------------------------------------
function imageDisplay_ButtonDownFcn(hObject, eventdata, handles)

% get coordinate of point, rounded 2 digits after point
point = get(handles.imageDisplay, 'currentPoint');
point = round((point(1,1:2)-1/handles.zoom)*100)/100;

set(handles.pointXText, 'String', num2str(point(2)));
set(handles.pointYText, 'String', num2str(point(1)));






