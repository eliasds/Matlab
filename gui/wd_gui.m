function varargout = wd_gui(varargin)
% WD_GUI MATLAB code for wd_gui.fig
%      WD_GUI, by itself, creates a new WD_GUI or raises the existing
%      singleton*.
%
%      H = WD_GUI returns the handle to a new WD_GUI or the handle to
%      the existing singleton*.
%
%      WD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WD_GUI.M with the given input arguments.
%
%      WD_GUI('Property','Value',...) creates a new WD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wd_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wd_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wd_gui

% Last Modified by GUIDE v2.5 18-Mar-2014 13:35:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wd_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @wd_gui_OutputFcn, ...
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


% --- Executes just before wd_gui is made visible.
function wd_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wd_gui (see VARARGIN)

% Choose default command line output for wd_gui
handles.output = hObject;

handles.internal.Directory = cd;
handles.internal.Filename = '';
handles.state.MovieFs = 0;
handles.state.View = false; %Raw, Construction, Whiskers
handles.state.raw.ComputeBGLimits = 'all';
handles.state.raw.Threshold = 0.05;
handles.state.raw.ErosionDim = 3;
handles.state.raw.NumSteps = 100;
handles.state.raw.Depths2Construct = [70E-03,90E-03];
handles.state.raw.Frames2Construct = 'all';

handles.state.construction.ColormapDirection = 'Z';
handles.state.construction.ColormapLength = 100;
handles.state.video.frameRate = 15;

% DON'T TOUCH
handles.state.construction.Colormap = colormap(hot(handles.state.construction.ColormapLength));
set(handles.figure1,'keypressfcn',@KeyPressCallback);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wd_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function KeyPressCallback(hObject,E)
handles = guidata(hObject);

if handles.state.View==false %nothing loaded
    switch E.Key
        case 'r' %load raw
            LoadRaw_Callback(handles.LoadRaw, [], handles);
        case 'c' %load construction
            LoadConstruction_Callback(handles.LoadConstruction, [], handles);
        case 'w' %load whiskers
            LoadWhiskers_Callback(handles.LoadWhiskers, [], handles);
    end
    
else
    
    switch E.Key
        case 'rightarrow' %move right one frame
            currentimg = round(get(handles.frameslider,'Value'));
            nextimg = currentimg + 1;
            if nextimg > handles.state.N
                nextimg = 1;
            end
            plotmainaxes(nextimg, handles);
        case 'leftarrow' %move left one frame
            currentimg = round(get(handles.frameslider,'Value'));
            nextimg = currentimg - 1;
            if nextimg < 1
                nextimg = get(handles.frameslider,'Max');
            end
            plotmainaxes(nextimg,handles);        
    end %switch E.Key
end %if handles.state.View

% --- Outputs from this function are returned to the command line.
function varargout = wd_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function plotmainaxes(frameindex, handles)
if isempty(frameindex)
    frameindex = handles.state.currentFrame;
else
    handles.state.currentFrame = frameindex;
    guidata(handles.mainaxes, handles);
end
set(handles.frameslider, 'Value', handles.state.currentFrame);
axes(handles.mainaxes);
cla
switch handles.state.View
    case 'Raw'
        Img = handles.Raw.Images(:,:,frameindex) - handles.Raw.Background;
        y1 = handles.Raw.ylimits(1);
        y2 = handles.Raw.ylimits(2);
        x1 = handles.Raw.xlimits(1);
        x2 = handles.Raw.xlimits(2);
        imagesc(Img(y1:y2,x1:x2));
        colormap gray
        axis off
        set(gca, 'TickDir', 'out')
    case 'Construction'
        Img = handles.Construction.Images(:,:,frameindex);
        switch handles.state.construction.ColormapDirection
            case 'Z'
                MinLim = handles.Construction.ZLim(1);
                MaxLim = handles.Construction.ZLim(2);
            case 'X'
                MinLim = 1;
                MaxLim = handles.Construction.W;
            case 'Y'
                MinLim = 1;
                MaxLim = handles.Construction.H;
        end
        ColormapIndex = MinLim:(MaxLim-MinLim)/(handles.state.construction.ColormapLength-1):MaxLim;
        ColormapIndex(end+1) = ColormapIndex(end) + 1e-5;
        [Y,X,Z] = find(Img); %indices of nonzero data
        hold on
        for i = 1:handles.state.construction.ColormapLength
            switch handles.state.construction.ColormapDirection
                case 'Z'
                    IndicesToPlot = find(ColormapIndex(i) <= Z & Z < ColormapIndex(i+1));
                case 'X'
                    IndicesToPlot = find(ColormapIndex(i) <= X & X < ColormapIndex(i+1));
                case 'Y'
                    IndicesToPlot = find(ColormapIndex(i) <= Y & Y < ColormapIndex(i+1));
            end
            plot3(X(IndicesToPlot),Y(IndicesToPlot),Z(IndicesToPlot),...
                '.', 'Color', handles.state.construction.Colormap(i,:));
        end
        hold off
        axis on
        grid on
        box on
%         set(gca, 'XLim', [1, handles.Construction.W],...
%             'YLim', [1 handles.Construction.H],...
%             'ZLim', handles.Construction.ZLim);
    case 'Whiskers'
        
end
set(handles.FrameText, 'String', sprintf('%d/%d', frameindex, handles.state.N));


% --------------------------------------------------------------------
function menu_file_Callback(~, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_raw_Callback(hObject, eventdata, handles)
% hObject    handle to menu_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_construction_Callback(hObject, eventdata, handles)
% hObject    handle to menu_construction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_whiskers_Callback(hObject, eventdata, handles)
% hObject    handle to menu_whiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function construction_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to construction_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ViewRaw_Callback(hObject, eventdata, handles)
% hObject    handle to ViewRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.N = handles.Raw.N;
    handles.state.View = 'Raw';
    if handles.state.currentFrame > handles.state.N
        handles.state.currentFrame = 1;
    end
    guidata(hObject, handles);
    if handles.state.N ~= 1
        set(handles.frameslider, 'Visible', 'on')
        set(handles.frameslider,'Min',1,'Max',handles.state.N,'Value',handles.state.currentFrame,...
            'SliderStep',[1/(handles.state.N-1),round(handles.state.N/4)/(handles.state.N-1)]);
    else
        set(handles.frameslider, 'Visible', 'off')
    end
    set(hObject, 'Checked', 'on')
    set([handles.ViewConstruction, handles.ViewWhiskers], 'Checked', 'off')
    set(handles.rawpanel, 'Visible', 'on')
    set([], 'Visible', 'off')
    plotmainaxes([], handles);
end


% --------------------------------------------------------------------
function ViewConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to ViewConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.N = handles.Construction.N;
    handles.state.View = 'Construction';
    if handles.state.currentFrame > handles.state.N
        handles.state.currentFrame = 1;
    end
    guidata(hObject, handles);
    if handles.state.N ~= 1
        set(handles.frameslider, 'Visible', 'on')
        set(handles.frameslider,'Min',1,'Max',handles.state.N,'Value',handles.state.currentFrame,...
            'SliderStep',[1/(handles.state.N-1),round(handles.state.N/4)/(handles.state.N-1)]);
    else
        set(handles.frameslider, 'Visible', 'off')
    end
    set(hObject, 'Checked', 'on')
    set([handles.ViewRaw, handles.ViewWhiskers], 'Checked', 'off')
    set([], 'Visible', 'on')
    set([handles.rawpanel], 'Visible', 'off')
    plotmainaxes([], handles);
end


% --------------------------------------------------------------------
function ViewWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to ViewWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.N = handles.Whiskers.N;
    handles.state.View = 'Whiskers';
    if handles.state.currentFrame > handles.state.N
        handles.state.currentFrame = 1;
    end
    guidata(hObject, handles);
    if handles.state.N ~= 1
        set(handles.frameslider, 'Visible', 'on')
        set(handles.frameslider,'Min',1,'Max',handles.state.N,'Value',handles.state.currentFrame,...
            'SliderStep',[1/(handles.state.N-1),round(handles.state.N/4)/(handles.state.N-1)]);
    else
        set(handles.frameslider, 'Visible', 'off')
    end
    set(hObject, 'Checked', 'on')
    set([handles.ViewConstruction, handles.ViewRaw], 'Checked', 'off')
    set([], 'Visible', 'on')
    set([handles.rawpanel], 'Visible', 'off')
    plotmainaxes([], handles);
end


% --------------------------------------------------------------------
function file_load_Callback(hObject, eventdata, handles)
% hObject    handle to file_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_save_Callback(hObject, eventdata, handles)
% hObject    handle to file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to SaveConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Construction = handles.Construction;
if isfield(handles.Construction, 'Filename')
    [p,f,~] = fileparts(handles.Construction.Filename);
else
    p = handles.internal.Directory;
    f = 'Construction.mat';
end
[f,p] = uiputfile({'*.mat'}, 'Save construction as:', fullfile(p,f));
handles.Construction.Filename = fullfile(p,f);
handles.internal.Directory = p;
guidata(hObject, handles);
save(handles.Construction.Filename, 'Construction');



% --------------------------------------------------------------------
function SaveWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to SaveWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Whiskers = handles.Whiskers;
if isfield(handles.Whiskers, 'Filename')
    [p,f,~] = fileparts(handles.Whiskers.Filename);
else
    p = handles.internal.Directory;
    f = 'Whiskers.mat';
end
[f,p] = uiputfile({'*.mat'}, 'Save construction as:', fullfile(p,f));
handles.Whiskers.Filename = fullfile(p,f);
handles.internal.Directory = p;
guidata(hObject, handles);
save(handles.Whiskers.Filename, 'Whiskers');


% --------------------------------------------------------------------
function SaveVideo_Callback(hObject, eventdata, handles)
% hObject    handle to SaveVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uiputfile({'*.avi','AVI video file (*.avi)'},...
    'Save Video');
if f==0 % user hit cancel
    return
end
Fs = inputdlg('Set Frame Rate of video (Hz):','Frame Rate',1,{num2str(handles.state.video.frameRate)});
if isempty(Fs) % user hit cancel
    return
else
    handles.state.video.frameRate = str2num(Fs{1});
end
numFrames = get(handles.frameslider, 'Max');

vidObj = VideoWriter(fullfile(p,f), 'Motion JPEG AVI');
set(vidObj, 'FrameRate', handles.state.video.frameRate);
open(vidObj);
for currentframe = 1:numFrames
    plotmainaxes(currentframe, handles);
    img = getframe(handles.mainaxes);
    writeVideo(vidObj,img);
end
close(vidObj);


% --------------------------------------------------------------------
function SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img = getframe(handles.mainaxes); % grab image
figure; image(img.cdata);
fn = sprintf('%sframe%s.tif',...
    handles.internal.Directory,handles.state.currentFrame);
[f,p,~] = uiputfile({'*.tif','tif file (*.tif)';...
    '*.jpg','jpeg file (*.jpg)';'*.*','All Files (*.*)'},...
    'Save Image',fn);
if ~f % user hit cancel
    return
end
imwrite(img.cdata,fullfile(p,f)); % save image
handles.state.previousDirectory=p;
guidata(hObject,handles);


% --------------------------------------------------------------------
function LoadRaw_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uigetfile({'*.seq';'*.tif'}, 'Choose SEQ file', handles.internal.Directory,...
    'Multiselect', 'on');
if ~iscell(f) && isscalar(f) && f==0 % user hit cancel
    return
end
handles.internal.Directory = p; %save directory
wb = waitbar(0, 'Loading raw images...');
if iscell(f)
    nfiles = length(f);
    handles.Raw.Filename = cell(nfiles,1);
    nFrames = zeros(nfiles,1);
    for n = 1:nfiles
        handles.Raw.Filename{n} = fullfile(p,f{n});
        info = imfinfo(handles.Raw.Filename{n});
        nFrames(n) = numel(info);
        handles.Raw.H = info.Height;
        handles.Raw.W = info.Width;
    end
    handles.Raw.Images = zeros(handles.Raw.H, handles.Raw.W, sum(nFrames));
    framecounter = 1;
    for n = 1:nfiles
        handles.Raw.Images(:,:,framecounter:framecounter+nFrames(n)-1) = imread(handles.Raw.Filename{n});
        framecounter = framecounter + nFrames(n);
        waitbar(n/nfiles, wb);
    end
else
    [~,~,e] = fileparts(f);
    switch e
        case 'seq'
            handles.Raw.Filename = fullfile(p,f); %save filename
            [handles.Raw.header, handles.Raw.Images] = Norpix2MATLAB(handles.Raw.Filename); %load images
            waitbar(1, wb);
    end
end
close(wb);
[handles.Raw.H, handles.Raw.W, handles.Raw.N] = size(handles.Raw.Images); %determine dimensions
handles.Raw.ylimits = [1,handles.Raw.H];
handles.Raw.xlimits = [1,handles.Raw.W];
handles.Raw.Background = zeros(handles.Raw.H, handles.Raw.W);
handles.state.currentFrame = 1; %display first frame
guidata(hObject, handles); %update handles
% Update gui
set([...
    handles.mainaxes,...
    handles.frameslider,...
    handles.moviebutton,...
    handles.file_save,...
    handles.menu_view,...
    handles.uitoolbar,...
    handles.file_export,...
    handles.menu_raw,...
    handles.ExportRaw,...
    handles.ViewRaw], 'Visible', 'on') %update gui
% Display First Frame
set(handles.ViewRaw, 'Checked', 'off') %in case of overwriting construction
ViewRaw_Callback(handles.ViewRaw, [], handles)


% --------------------------------------------------------------------
function LoadConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to LoadConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Select File
[f,p] = uigetfile({'*.mat'}, 'Choose MAT file', handles.internal.Directory,...
    'Multiselect', 'off');
if f==0 % user hit cancel
    return
end
handles.internal.Directory = p; %save directory
handles.Construction.Filename = fullfile(p,f); %save filename
% Load File
temp = load(handles.Construction.Filename); %load images
% handles.Construction = temp.Construction; %load in struct created in previous session
% .H, .W, .N, .ColormapIndex, .Images
whiskers = temp.whiskers;
[y,x] = size(whiskers(1).time);
handles.Construction.Images = reshape(struct2array(whiskers), y, x, length(whiskers));
[handles.Construction.H, handles.Construction.W, handles.Construction.N] = size(handles.Construction.Images);
zeroindices = handles.Construction.Images == 0;
handles.Construction.ZLim = [min(handles.Construction.Images(~zeroindices)),max(handles.Construction.Images(~zeroindices))];
handles.state.currentFrame = 1; %display first frame
guidata(hObject, handles); %update handles
% Update gui
set([...
    handles.mainaxes,...
    handles.frameslider,...
    handles.moviebutton,...
    handles.file_save,...
    handles.menu_view,...
    handles.uitoolbar,...
    handles.file_export,...
    handles.menu_construction,...
    handles.SaveConstruction,...
    handles.ExportConstruction,...
    handles.ViewConstruction], 'Visible', 'on') %update gui
% Display First Frame
set(handles.ViewConstruction, 'Checked', 'off') %in case of overwriting construction
ViewConstruction_Callback(handles.ViewConstruction, [], handles)


% --------------------------------------------------------------------
function LoadWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to LoadWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [f,p] = uigetfile({'*.mat'}, 'Choose MAT file', handles.internal.Directory,...
%     'Multiselect', 'off');
% if f==0 % user hit cancel
%     return
% end
% handles.internal.Directory = p; %save directory
% handles.Whiskers.Filename = fullfile(p,f); %save filename

% handles.Whiskers.Images = ...

% [handles.Whiskers.H, handles.Whiskers.W, handles.Whiskers.N] = size(handles.Whiskers.Images); %determine dimensions
% handles.state.View = 'Whiskers'; %change state to view newly loaded images
% guidata(hObject, handles); %update handles
% set([...
%     handles.mainaxes,...
%     handles.frameslider,...
%     handles.moviebutton,...
%     handles.file_save,...
%     handles.menu_view,...
%     handles.uitoolbar,...
%     handles.menu_whiskers,...
%     handles.SaveWhiskers,...
%     handles.ViewWhiskers], 'Visible', 'on') %update gui


% --------------------------------------------------------------------
function ColormapZ_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.construction.ColormapDirection = 'Z';
    guidata(hObject, handles)
    set(hObject, 'Checked', 'on')
    set([handles.ColormapX, handles.ColormapY], 'Checked', 'off')
    plotmainaxes([], handles)
end


% --------------------------------------------------------------------
function ColormapX_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.construction.ColormapDirection = 'X';
    guidata(hObject, handles)
    set(hObject, 'Checked', 'on')
    set([handles.ColormapZ, handles.ColormapY], 'Checked', 'off')
    plotmainaxes([], handles)
end


% --------------------------------------------------------------------
function ColormapY_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.construction.ColormapDirection = 'Y';
    guidata(hObject, handles)
    set(hObject, 'Checked', 'on')
    set([handles.ColormapX, handles.ColormapZ], 'Checked', 'off')
    plotmainaxes([], handles)
end


% --------------------------------------------------------------------
function ColormapWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to ColormapWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function frameslider_Callback(hObject, eventdata, handles)
% hObject    handle to frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
plotmainaxes(round(get(hObject,'Value')), handles);


% --- Executes during object creation, after setting all properties.
function frameslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function RawCrop_Callback(hObject, eventdata, handles)
% hObject    handle to RawCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Raw.xlimits = [1,handles.Raw.W];
handles.Raw.ylimits = [1,handles.Raw.H];
plotmainaxes([], handles); %display whole image
[~, rect] = imcrop(handles.mainaxes); %ui cropping tool
handles.Raw.xlimits = [floor(rect(1)+.5), floor(rect(1)+.5+rect(3))]; %[xmin, xmin + width] (subtract 0.5 to convert from spatial to pixel coordinates)
handles.Raw.ylimits = [floor(rect(2)+.5), floor(rect(2)+.5+rect(4))]; %[ymin, ymin + height] (subtract 0.5 to convert from spatial to pixel coordinates)
guidata(hObject, handles); %save new cropping coordinates
plotmainaxes([], handles) %display newly cropped image

% --------------------------------------------------------------------
function file_export_Callback(hObject, eventdata, handles)
% hObject    handle to file_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ExportRaw_Callback(hObject, eventdata, handles)
% hObject    handle to ExportRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varname = 'Raw';
var = handles.Raw;
num_append = 0;
while evalin('base', sprintf('exist(''%s'', ''var'')',varname))
    num_append = num_append + 1;
    varname = strcat(varname,num2str(num_append));
end
assignin('base', varname, var)


% --------------------------------------------------------------------
function ExportConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to ExportConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varname = 'Construction';
var = handles.Construction;
num_append = 0;
while evalin('base', sprintf('exist(''%s'', ''var'')',varname))
    num_append = num_append + 1;
    varname = strcat(varname,num2str(num_append));
end
assignin('base', varname, var)


% --------------------------------------------------------------------
function ExportWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to ExportWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varname = 'Whiskers';
var = handles.Whiskers;
num_append = 0;
while evalin('base', sprintf('exist(''%s'', ''var'')',varname))
    num_append = num_append + 1;
    varname = strcat(varname,num2str(num_append));
end
assignin('base', varname, var)


% --- Executes on button press in ComputeBackground.
function ComputeBackground_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wb = waitbar(0, 'Calculating Background...');
if strcmp(handles.state.raw.ComputeBGLimits, 'all')
    handles.Raw.ComputeBGlimits = 1:handles.Raw.N;
    handles.Raw.Background = mean(handles.Raw.Images,3);
elseif strcmp(handles.state.raw.ComputeBGLimits, 'none')
    handles.Raw.Background = zeros(handles.Raw.H, handles.Raw.W);
else
    handles.Raw.computeBGlimits = round(str2num(handles.state.raw.ComputeBGLimits));
    handles.Raw.Background = mean(handles.Raw.Images(:,:,handles.Raw.computeBGlimits),3);
end
guidata(hObject, handles)
waitbar(1, wb);
close(wb)
plotmainaxes([], handles);


function ComputeBackgroundLimits_Callback(hObject, eventdata, handles)
% hObject    handle to ComputeBackgroundLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ComputeBackgroundLimits as text
%        str2double(get(hObject,'String')) returns contents of ComputeBackgroundLimits as a double
temp = get(hObject, 'String');
if ~strcmp(temp, 'all') && ~strcmp(temp, 'none')
    temp = str2num(temp);
    if isempty(temp)
        set(hObject, 'String', handles.state.raw.ComputeBGLimits)
        error('needs to be a vector of frame indices, ''none'', or ''all''')
    elseif temp(1) < 1
        set(hObject, 'String', handles.state.raw.ComputeBGLimits)
        error('indices need to be >= 1')
    elseif temp(end) > handles.Raw.N
        set(hObject, 'String', handles.state.raw.ComputeBGLimits)
        error('indices need to be <= %d', handles.Raw.N)
    end
end
handles.state.raw.ComputeBGLimits = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ComputeBackgroundLimits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ComputeBackgroundLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RawThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to RawThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawThreshold as text
%        str2double(get(hObject,'String')) returns contents of RawThreshold as a double
temp = str2double(get(hObject, 'String'));
if isnan(temp)
    set(hObject, 'String', num2str(handles.state.raw.Threshold))
    error('Input needs to be a scalar value')
end
handles.state.raw.Threshold = temp;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function RawThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ErosionSize_Callback(hObject, eventdata, handles)
% hObject    handle to ErosionSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ErosionSize as text
%        str2double(get(hObject,'String')) returns contents of ErosionSize as a double
temp = round(str2double(get(hObject, 'String')));
if isnan(temp)
    set(hObject, 'String', num2str(handles.state.raw.ErosionDim))
    error('Input needs to be an integer')
end
handles.state.raw.ErosionDim = temp;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function ErosionSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ErosionSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RawDepths_Callback(hObject, eventdata, handles)
% hObject    handle to RawDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawDepths as text
%        str2double(get(hObject,'String')) returns contents of RawDepths as a double
temp = str2num(get(hObject, 'String'));
if isnan(temp)
    set(hObject, 'String', num2str(handles.state.raw.Depths2Construct))
    error('Input needs to be an integer')
elseif length(temp) < 2 || length(temp) > 2
    set(hObject, 'String', num2str(handles.state.raw.Depths2Construct))
    error('Depth requires a minimum and a maximum value')
end
handles.state.raw.Depths2Construct = sort(temp);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function RawDepths_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawDepths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RawReconstruct.
function RawReconstruct_Callback(hObject, eventdata, handles)
% hObject    handle to RawReconstruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Threshold = handles.state.raw.Threshold;
temp = cellstr(get(handles.RawErodeDir,'String'));
ErosionDir = temp{get(handles.RawErodeDir,'Value')};
ErosionDim = handles.state.raw.ErosionDim;
NumSteps = handles.state.raw.NumSteps;
if strcmp(handles.state.raw.Frames2Construct, 'all')
    FrameIndices = 1:handles.Raw.N;
else
   FrameIndices = round(str2num(handles.state.raw.Frames2Construct));
end
MinDepth = handles.state.raw.Depths2Construct(1);
MaxDepth = handles.state.raw.Depths2Construct(2);

handles.Construction.Images = wd_run_evan(...
    handles.Raw.Images(:,:,FrameIndices),...
    handles.Raw.Background,...
    Threshold,...
    ErosionDim,...
    ErosionDir,...
    NumSteps,...
    MinDepth,...
    MaxDepth,...
    [handles.Raw.xlimits, handles.Raw.ylimits]);

[handles.Construction.H, handles.Construction.W, handles.Construction.N] = size(handles.Construction.Images);
zeroindices = handles.Construction.Images == 0;
handles.Construction.ZLim = [min(handles.Construction.Images(~zeroindices)),max(handles.Construction.Images(~zeroindices))];
handles.state.currentFrame = 1; %display first frame
guidata(hObject, handles); %update handles
% Update gui
set([...
    handles.mainaxes,...
    handles.frameslider,...
    handles.file_save,...
    handles.menu_view,...
    handles.uitoolbar,...
    handles.file_export,...
    handles.menu_construction,...
    handles.SaveConstruction,...
    handles.ExportConstruction,...
    handles.ViewConstruction], 'Visible', 'on') %update gui
% Display First Frame
set(handles.ViewConstruction, 'Checked', 'off') %in case of overwriting construction
ViewConstruction_Callback(handles.ViewConstruction, [], handles)


function RawFrames2Compute_Callback(hObject, eventdata, handles)
% hObject    handle to RawFrames2Compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawFrames2Compute as text
%        str2double(get(hObject,'String')) returns contents of RawFrames2Compute as a double
temp = get(hObject, 'String');
if ~strcmp(temp, 'all')
    temp = str2num(temp);
    if isempty(temp)
        set(hObject, 'String', handles.state.raw.Frames2Construct)
        error('needs to be a vector of frame indices or ''all''')
    elseif temp(1) < 1
        set(hObject, 'String', handles.state.raw.Frames2Construct)
        error('indices need to be >= 1')
    elseif temp(end) > handles.Raw.N
        set(hObject, 'String', handles.state.raw.Frames2Construct)
        error('indices need to be <= %d', handles.Raw.N)
    end
end
handles.state.raw.Frames2Construct = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RawFrames2Compute_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawFrames2Compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RawErodeDir.
function RawErodeDir_Callback(hObject, eventdata, handles)
% hObject    handle to RawErodeDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RawErodeDir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RawErodeDir


% --- Executes during object creation, after setting all properties.
function RawErodeDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawErodeDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RawHistogram.
function RawHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to RawHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RawHistogram
figure;
% imhist(handles.Raw.Images(:,:,handles.state.currentFrame));
temp = handles.Raw.Images(:,:,handles.state.currentFrame); % - handles.Raw.Background;
M = max(temp(:));
m = min(temp(:));
counts = hist(temp(:), m:(M-m)/199:M);
plot(m:(M-m)/199:M, counts, '-')
xlim([m,M])
xlabel('pixel value')
ylabel('number of pixels')


% --- Executes on button press in moviebutton.
function moviebutton_Callback(hObject, eventdata, handles)
% hObject    handle to moviebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(hObject,'String','Stop')
    if handles.state.currentFrame == handles.state.N
        startimg = 1;
    else
        startimg=handles.state.currentFrame;
    end
    for index = startimg:handles.state.N
        if get(hObject,'Value')
            plotmainaxes(index,handles);
            if handles.state.MovieFs
                pause(1/handles.state.MovieFs);
            end
        else
            return
        end
    end
    set(hObject, 'Value', 0)
    set(hObject, 'String', 'Play')
else
    set(hObject, 'String', 'Play')
end


function RawNumSteps_Callback(hObject, eventdata, handles)
% hObject    handle to RawNumSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RawNumSteps as text
%        str2double(get(hObject,'String')) returns contents of RawNumSteps as a double
temp = round(str2double(get(hObject, 'String')));
if isnan(temp)
    set(hObject, 'String', num2str(handles.state.raw.ErosionDim))
    error('Input needs to be an integer')
end
handles.state.raw.NumSteps = temp;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function RawNumSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RawNumSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
