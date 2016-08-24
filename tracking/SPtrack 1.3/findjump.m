function varargout = findjump(varargin)
% FINDJUMP M-file for findjump.fig
%      FINDJUMP, by itself, creates a new FINDJUMP or raises the existing
%      singleton*.
%
%      H = FINDJUMP returns the handle to a new FINDJUMP or the handle to
%      the existing singleton*.
%
%      FINDJUMP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDJUMP.M with the given input arguments.
%
%      FINDJUMP('Property','Value',...) creates a new FINDJUMP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findjump_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findjump_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help findjump

% Last Modified by GUIDE v2.5 16-Jun-2008 16:14:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findjump_OpeningFcn, ...
                   'gui_OutputFcn',  @findjump_OutputFcn, ...
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


% --- Executes just before findjump is made visible.
function findjump_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findjump (see VARARGIN)

% Choose default command line output for findjump
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes findjump wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = findjump_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

diffinput
