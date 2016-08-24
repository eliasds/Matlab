function varargout = msdgui(varargin)
% MSDGUI M-file for msdgui.fig
%      MSDGUI, by itself, creates a new MSDGUI or raises the existing
%      singleton*.
%
%      H = MSDGUI returns the handle to a new MSDGUI or the handle to
%      the existing singleton*.
%
%      MSDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MSDGUI.M with the given input arguments.
%
%      MSDGUI('Property','Value',...) creates a new MSDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before msdgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to msdgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help msdgui

% Last Modified by GUIDE v2.5 21-May-2008 17:50:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @msdgui_OpeningFcn, ...
                   'gui_OutputFcn',  @msdgui_OutputFcn, ...
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


% --- Executes just before msdgui is made visible.
function msdgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to msdgui (see VARARGIN)

% Choose default command line output for msdgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes msdgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = msdgui_OutputFcn(hObject, eventdata, handles) 
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
dataimport=importdata('xy-data.txt');%import data file name 'Example xy-data.txt'
coordinates=dataimport; 

px=coordinates(:,1);
py=coordinates(:,2);

fid = fopen('msd_parameter.m','r');
A = fscanf(fid,'%f');
fclose(fid);
k= A(1,1);  % Number of Interval Time
m= A(2,1)   ;   % Maximum interesting Frame
%@@@ Warning m + k <= N @@@@

%double average
for dt = 1:m  
     diffxA = px(1:k) - px((1+dt):(k+dt));%calculate diffuse step on x
     diffyA = py(1:k) - py((1+dt):(k+dt));%calculate diffuse step on y
     ACxsquare = diffxA.*diffxA;
     ACysquare = diffyA.*diffyA;
     ACrsquare = diffxA.*diffxA + diffyA.*diffyA;% displacement square
     ACmeanxsquare(dt) = mean(ACxsquare);
     ACmeanysquare(dt) = mean(ACysquare);
     ACmeanrsquare(dt) = mean(ACrsquare);% MSD in one step
end; 
%-----------------------------
 aa1 = 1:m;
 fid1 = fopen('RMSD.dat','a+') 
 fid2 = fopen('StepTime.dat','a+') 
 StepTime = aa1';
 fprintf(fid2,' %12.3f\n',aa1');
 Tcutoff = 1./StepTime;
 xMSD = ACmeanxsquare';
 XMSD=xMSD;
 yMSD = ACmeanysquare';
 YMSD=yMSD;
 RMSD = ACmeanrsquare';
fprintf(fid1,' %12.3f\n',ACmeanrsquare');
fclose(fid1);
fclose(fid2);
 %---------------------------%
     prx  = sqrt(ACxsquare);
     pry  = sqrt(ACysquare);
     prr  = sqrt(ACrsquare);
     prs  = sqrt(px.*px + py.*py);


% Find Waiting Time - PDF by FFT
    fftpr = abs(fft(prr)); wfftpr = 1:k;
   Lfftpr = log10(fftpr); Lwfftpr = log10(wfftpr)';
   
% Find Waiting Time - PDF by pwelch-Function
% calculate power spectrum density(PSD) see MSD related to PSD
 [Pxx,wx] = pwelch(px);
 [Pyy,wy] = pwelch(py);
 [Prx,wrx]  = pwelch(prx);
 [Pry,wry]  = pwelch(pry);
 [Pr,wr]  = pwelch(prr);
 [Prs,wrs]  = pwelch(prs);
%---------------------------------
[pxN wxN]=size(Pxx);
[pyN wyN]=size(Pyy);
[prsN wrsN]=size(Prs);
%--------------Graph-------------%
figure()% scatter plot of position
plot(px,py,'.-');
grid on
title('Brownain Motion Trajectory');
xlabel('x');
ylabel('y');

%-----------------------
msdfitinfo
%figure()%plot power spectrum see 'pwelch' in Help
%subplot(311);
%plot(log10(wx(10:pxN)),log10(Pxx(10:pxN)),'-*r');
%title({' ';'PowerSpectrum Density x,y,R positions'});
%xlabel('frequency');
%ylabel('P(x)');
% subplot(312);
% plot(log10(wy(5:pyN)),log10(Pyy(5:pyN)),'-*g');
% xlabel('frequency');
% ylabel('P(y)');
% subplot(313);
% plot(log10(wrs(5:prsN)),log10(Prs(5:prsN)),'-*b');
% xlabel('frequency');
% ylabel('P(R)');
%------------------------
% figure()%plot MSD
% plot(log10(StepTime(1:180)),log10(RMSD(1:180)),'-*');
% title('Mean Square Displacement of Brownain Motion');
% xlabel('time step');
% ylabel('MSD');
% 
% 

% [R]= RMSD
% figure()%plot MSD
% plot(RMSD,StepTime,'-*');
% title('Mean Square Displacement of Brownain Motion');
% xlabel('time step');
% ylabel('MSD');