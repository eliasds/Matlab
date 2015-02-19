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

% Last Modified by GUIDE v2.5 17-Feb-2014 17:21:19

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
handles.state.View = false; %Raw, Construction, Whiskers
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
            if nextimg > get(handles.frameslider,'Max');
                nextimg = 1;
            end
            set(handles.frameslider,'value',nextimg);
            plotmainaxes(nextimg, handles);
        case 'leftarrow' %move left one frame
            currentimg = round(get(handles.frameslider,'Value'));
            nextimg = currentimg - 1;
            if nextimg < get(handles.frameslider,'Min');
                nextimg = get(handles.frameslider,'Max');
            end
            set(handles.frameslider,'value',nextimg);
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
axes(handles.mainaxes);
cla
switch handles.state.View
    case 'Raw'
        Img = handles.Raw.Images(:,:,frameindex);
        imagesc(Img);
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
        grid on
        box on
        set(gca, 'XLim', [1, handles.Construction.W],...
            'YLim', [1 handles.Construction.H],...
            'ZLim', [handles.Construction.ZLim(1) handles.Construction.ZLim(2)]);
    case 'Whiskers'
        
end


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
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
    handles.state.View = 'Raw';
    guidata(hObject, handles);
    set(hObject, 'Checked', 'on')
    set([handles.ViewConstruction, handles.ViewWhiskers], 'Checked', 'off')
    plotmainaxes([], handles);
end


% --------------------------------------------------------------------
function ViewConstruction_Callback(hObject, eventdata, handles)
% hObject    handle to ViewConstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.View = 'Construction';
    guidata(hObject, handles);
    set(hObject, 'Checked', 'on')
    set([handles.ViewRaw, handles.ViewWhiskers], 'Checked', 'off')
    plotmainaxes([], handles);
end


% --------------------------------------------------------------------
function ViewWhiskers_Callback(hObject, eventdata, handles)
% hObject    handle to ViewWhiskers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject, 'Checked'), 'off')
    handles.state.View = 'Whiskers';
    guidata(hObject, handles);
    set(hObject, 'Checked', 'on')
    set([handles.ViewConstruction, handles.ViewRaw], 'Checked', 'off')
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
function LoadRaw_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [f,p] = uigetfile({'*.seq'}, 'Choose SEQ file', handles.internal.Directory,...
%     'Multiselect', 'off');
% if f==0 % user hit cancel
%     return
% end
% handles.internal.Directory = p; %save directory
% handles.Raw.Filename = fullfile(p,f); %save filename
% [~, handles.Raw.Images] = Norpix2MATLAB(handles.Raw.Filename); %load images
% [handles.Raw.H, handles.Raw.W, handles.Raw.N] = size(handles.Raw.Images); %determine dimensions
% handles.state.View = 'Raw'; %change state to view newly loaded images
% guidata(hObject, handles); %update handles
% set(handles.ViewRaw, 'Checked', on)
% set(handles.frameslider,'Min',1,'Max',handles.Raw.N,'Value',1,...
%     'SliderStep',[1/(handles.Raw.N-1),round(handles.Raw.N/4)/(handles.Raw.N-1)]);
% set([...
%     handles.mainaxes,...
%     handles.frameslider,...
%     handles.file_save,...
%     handles.menu_view,...
%     handles.uitoolbar,...
%     handles.menu_raw,...
%     handles.ViewRaw], 'Visible', 'on') %update gui
% plotmainaxes(1, handles); %display first image


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
% Update guidata
handles.state.View = 'Construction'; %change state to view newly loaded images
guidata(hObject, handles); %update handles
% Update gui
set(handles.ViewConstruction, 'Checked', 'on')
set(handles.frameslider,'Min',1,'Max',handles.Construction.N,'Value',1,...
    'SliderStep',[1/(handles.Construction.N-1),round(handles.Construction.N/4)/(handles.Construction.N-1)]);
set([...
    handles.mainaxes,...
    handles.frameslider,...
    handles.file_save,...
    handles.menu_view,...
    handles.uitoolbar,...
    handles.menu_construction,...
    handles.SaveConstruction,...
    handles.ViewConstruction], 'Visible', 'on') %update gui
% Display First Figure
plotmainaxes(1, handles); %display first image


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
% set(handles.ViewWhiskers, 'Checked', on)
% set(handles.frameslider,'Min',1,'Max',handles.Whiskers.N,'Value',1,...
%     'SliderStep',[1/(handles.Whiskers.N-1),round(handles.Whiskers.N/4)/(handles.Whiskers.N-1)]);
% set([...
%     handles.mainaxes,...
%     handles.frameslider,...
%     handles.file_save,...
%     handles.menu_view,...
%     handles.uitoolbar,...
%     handles.menu_whiskers,...
%     handles.SaveWhiskers,...
%     handles.ViewWhiskers], 'Visible', 'on') %update gui
% plotmainaxes(1, handles); %display first image


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
