function varargout = ParticleAnalysisProgram(varargin)
% PARTICLEANALYSISPROGRAM M-file for ParticleAnalysisProgram.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParticleAnalysisProgram_OpeningFcn, ...
                   'gui_OutputFcn',  @ParticleAnalysisProgram_OutputFcn, ...
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


% --- Executes just before ParticleAnalysisProgram is made visible.
function ParticleAnalysisProgram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParticleAnalysisProgram (see VARARGIN)

% Choose default command line output for ParticleAnalysisProgram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ParticleAnalysisProgram wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ParticleAnalysisProgram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global XY_Data;
XY_Data=[];
global img;
img=[];
global cal;
cal=1;


% --- Executes on button press in OpenButton.
function OpenButton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path, num] = uigetfile('c:\Documents and Settings\Stephanie\Desktop\*.tif', 'Open Image');
set(handles.ImageText, 'String', strcat(path, file));
global img;
global lengths;
global Z;
global XY_Data;
global image_handle;
global points_handle;
lengths = [0.0];

if (~isempty(img))
    delete(image_handle);
end

if (~isempty(XY_Data))
    XY_Data=[];
    delete(points_handle);
end

img = imread(strcat(path, file), 'TIFF');

Z=img;

imagesc(img);
hold on;
axis equal; axis tight;
hold off;

colormap(gray);
image_handle=imagesc(img);


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global lengths;
global r_R;
global pair_correlation;
global P_C_Data;

[file, path] = uiputfile('c:\Documents and Settings\Stephanie\Desktop\*.csv', 'Save to'); 
csvwrite(strcat(path, file), P_C_Data);

% --- Executes on button press in CalibrateButton.
function CalibrateButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalibrateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x, y] = ginput(2);
cal_pix = abs( y(2) - y(1) );
cal_dst = str2num(get(handles.CalInput, 'String'));
global cal;
cal = cal_dst/cal_pix;
set(handles.CalText, 'String', num2str(cal));

function CalInput_Callback(hObject, eventdata, handles)
% hObject    handle to CalInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CalInput as text
%        str2double(get(hObject,'String')) returns contents of CalInput as a double


% --- Executes during object creation, after setting all properties.
function CalInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DataShow.
function DataShow_Callback(hObject, eventdata, handles)
% hObject    handle to DataShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DataShow contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DataShow


% --- Executes during object creation, after setting all properties.
function DataShow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Pic_Points.
function Pic_Points_Callback(hObject, eventdata, handles)
% hObject    handle to Pic_Points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormap(gray)
global x_particle;
global y_particle;
global npoints;
global XY_Data;
global cal;
global points_handle;

%[x_particle,y_particle] = ginput;

%axis([0 length(img(1,:)) 0 length(img(:,1))]);
hold on
%Loop, picking up the points.
xy = [];
n = 0;
but = 1;
while but ~=13
    [xi,yi,but] = ginput(1);
    if but==1
        points_handle=plot(xi,yi,'bo', 'MarkerSize', 5);
        n = n+1;
        xy(n,:) = [xi yi];
    else if but==3
        TRI=delaunay(xy(:,1),xy(:,2));
        K = dsearchn(xy,TRI,[xi yi]);
        
        hold on
        points_handle=plot(xy(K,1),xy(K,2),'ro', 'MarkerSize', 5);
        hold on
        points_handle=plot(xy(K,1),xy(K,2),'rx', 'MarkerSize', 5);
        xy = [xy(1:K-1,:); xy(K+1:n,:)];
        n=n-1;
        hold on
        points_handle=plot(xy(:,1),xy(:,2),'bo', 'MarkerSize', 5);
        end
    end
end

hold off;

if (isempty(XY_Data))
    npoints = size(x_particle,1);
    XY_Data = xy*cal;
    x_particle =xy(:,1)*cal;
    y_particle =xy(:,2)*cal;
else
    npoints = size(x_particle,1)+ size(xy,1);
    XY_Data = [XY_Data; xy*cal];
    x_particle =[x_particle; xy(:,1)*cal];
    y_particle =[y_particle; xy(:,2)*cal];
end

% --- Executes on button press in Select_ROI_Points.
function Select_ROI_Points_Callback(hObject, eventdata, handles)
% hObject    handle to Select_ROI_Points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global x_particle;
global y_particle;
global npoints;
global XY_Data;
global cal;

[x_min x_max y_min y_max]=select_roi_points()
x_min=x_min
x_max=x_max
y_min=y_min
y_max=y_max

XY_ROI_Data=XY_Data(find([[XY_Data(:,1)<x_max].*XY_Data(:,1)>x_min]==1),:);
XY_ROI_Data=XY_ROI_Data(find([[XY_ROI_Data(:,2)<y_max].*XY_ROI_Data(:,2)>y_min]==1),:);



% --- Executes on button press in Calculate.
function Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global XY_Data;

q=gofrone2D(XY_Data);
figure;
plot(q(:,1),q(:,2));

global P_C_Data;    
P_C_Data = [q(:,1) q(:,2)];




% --- Executes on button press in SaveXYData.
function SaveXYData_Callback(hObject, eventdata, handles)
% hObject    handle to SaveXYData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global x_particle;
global y_particle;
global cal;

global XY_Data;

XY_Data = cal*[x_particle y_particle]';

[file, path] = uiputfile('c:\Documents and Settings\Stephanie\Desktop\*.csv', 'Save to'); 
csvwrite(strcat(path, file), XY_Data');




% --- Executes on button press in FFT_Photo.
function FFT_Photo_Callback(hObject, eventdata, handles)
% hObject    handle to FFT_Photo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;

FFT_Pic = fftshift(fft2((img)));
figure;
imshow(log(abs(FFT_Pic)),[]), colormap(gray);



% --- Executes on button press in Open_Points.
function Open_Points_Callback(hObject, eventdata, handles)
% hObject    handle to Open_Points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global x_particle;
global y_particle;
global npoints;
global img;
global cal;
global XY_Data;
global points_handle;
global image_handle;

if (~isempty(XY_Data))
    delete(points_handle);
end

if (~isempty(img))
    img=[];
    delete(image_handle);
end

[file, path, num] = uigetfile('c:\Documents and Settings\Stephanie\Desktop\*.csv', 'Open Points');
set(handles.ImageText, 'String', strcat(path, file));

XY_Data = csvread(strcat(path, file));

% points_handle=scatter(XY_Data(:,1),XY_Data(:,2));
points_handle=plot(XY_Data(:,1),XY_Data(:,2),'bo', 'MarkerSize', 5);

x_particle = XY_Data(:,1);
y_particle = XY_Data(:,2);
npoints = size(x_particle,1);
cal = 1;


% --- Executes on button press in Make_Voronoi.
function Make_Voronoi_Callback(hObject, eventdata, handles)
% hObject    handle to Make_Voronoi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global XY_Data;
global x_particle;
global y_particle;

figure;
colormap(winter);
%voronoi(x_particle,y_particle);

%h=voronoi(x_particle,y_particle)
[v,c]=voronoin(XY_Data);

for i = 1:length(c) 
if all(c{i}~=1)   % If at least one of the indices is 1, 
                  % then it is an open region and we can't 
                  % patch that.
patch(v(c{i},1),v(c{i},2),size(c{i},2)); % use color i. 
end
end
axis equal




% --- Executes on button press in Make_Delaunay.
function Make_Delaunay_Callback(hObject, eventdata, handles)
% hObject    handle to Make_Delaunay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global XY_Data;
global x_particle;
global y_particle;

figure;
colormap(winter);

tri = delaunay(x_particle,y_particle);
trisurf(tri,x_particle,y_particle,zeros(size(x_particle)));


% --- Executes on button press in structure_factor.
function structure_factor_Callback(hObject, eventdata, handles)
% hObject    handle to structure_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global XY_Data;
global x_particle;
global y_particle;


mid_x=(max(x_particle)+min(x_particle))/2;
mid_y=(max(y_particle)+min(y_particle))/2;
a=delaunay(x_particle,y_particle);
k=dsearchn([x_particle y_particle],a,[mid_x mid_y]);
mid_x=x_particle(k);
mid_y=y_particle(k);

x_particle = x_particle - mid_x;
y_particle = y_particle - mid_y;

xx = -10+min(x_particle):pi/(max(x_particle)-min(x_particle))/2:max(x_particle)+10;
yy = -10+min(y_particle):pi/(max(x_particle)-min(x_particle))/2:max(y_particle)+10;      

% for cnt1=1:length(yy)
%     for cnt2=1:length(xx)
%         S(cnt1,cnt2)=0;
%     end
% end

S=zeros(length(yy),length(xx));

count = length(yy);

for cnt1=1:length(yy)
    for cnt2=1:length(xx)
        for cnt3=1:length(x_particle)
            a=exp(1i*(x_particle(cnt3)*xx(cnt2)+y_particle(cnt3)*yy(cnt1)));
            S(cnt1,cnt2)=a+S(cnt1,cnt2);
        end
        S(cnt1,cnt2)= S(cnt1,cnt2)*conj(S(cnt1,cnt2));
    end
    count=count-1;
    disp(count);
end

S=S/length(x_particle);
% figure;
% contour(xx,yy,S);
% colormap jet;
figure;
image(S);
colormap jet


disp('q_x conversion')
(max(x_particle)-min(x_particle))/length(S(1,:))

disp('q_y conversion')
(max(y_particle)-min(y_particle))/length(S(:,1))


% --- Executes on button press in Calc_O6_PairC.
function Calc_O6_PairC_Callback(hObject, eventdata, handles)
% hObject    handle to Calc_O6_PairC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global XY_Data;

q=g6ofrone2D(XY_Data);
figure
plot(q(:,1),q(:,5));

global P_C_Data;    
P_C_Data = [q(:,1) q(:,5)];




% --- Executes on button press in BondOrder.
function BondOrder_Callback(hObject, eventdata, handles)
% hObject    handle to BondOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global x_particle;
global y_particle;

%%%%%%%%%%%%%%%%%%%%%%Nearest Neighbour Code%%%%%%%%%%%%%%%%%%%%%
[nn, num_nn]=nearest_neighbour(x_particle, y_particle);

S1=0;
for cnt1=1:length(x_particle)
    if (num_nn(cnt1)==6)
    S2=0;
    for cnt2=1:num_nn(cnt1)
        h=x_particle(nn{cnt1}(cnt2))-x_particle(cnt1);
        v=y_particle(nn{cnt1}(cnt2))-y_particle(cnt1);
        if (h==0)
            theta = (atan(inf));
        else
            theta = (atan(v/h));
        end
        S2 = S2 + exp(sqrt(-1)*(6*theta));
    end
    S2=S2/num_nn(cnt1)
    S1=S1+S2;
    end
end

S1=abs(S1)/length(x_particle);

disp(S1);


% --- Executes on button press in particle_track.
function particle_track_Callback(hObject, eventdata, handles)
% hObject    handle to particle_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img;
global x_particle;
global y_particle;
global XY_Data;
global cal;

image_process1=str2num(get(handles.image_process1, 'String')); 
image_process2=str2num(get(handles.image_process2, 'String'));

a=img;


b = bpass(a,image_process1,image_process2);
pk = pkfnd(b,35,10);
cnt = cntrd(b,pk,10);

hold on;
plot(cnt(:,1),cnt(:,2),'bo', 'MarkerSize', 2); %axis image; axis ij; axis tight;

% figure;
% subplot(2,2,2); imagesc(b); axis image;
% subplot(2,2,3); plot(cnt(:,1)*cal,cnt(:,2)*cal,'bo', 'MarkerSize', 2); axis image; axis ij;
% subplot(2,2,1); colormap('gray'), imagesc(a); axis image; hold on;
% subplot(2,2,1); plot(cnt(:,1),cnt(:,2),'bo', 'MarkerSize', 2); axis image; axis ij;

x_particle=cnt(:,1)*cal;
y_particle=cnt(:,2)*cal;
XY_Data = [cnt(:,1) cnt(:,2)]*cal;




% --- Executes on button press in image_process.
function image_process_Callback(hObject, eventdata, handles)
% hObject    handle to image_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global img;

image_process1=str2num(get(handles.image_process1, 'String')); 
image_process2=str2num(get(handles.image_process2, 'String'));

a=img;
figure;
b = bpass(a,image_process1,image_process2);
colormap('gray'), imagesc(b); axis image;



function image_process1_Callback(hObject, eventdata, handles)
% hObject    handle to image_process1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of image_process1 as text
%        str2double(get(hObject,'String')) returns contents of image_process1 as a double


% --- Executes during object creation, after setting all properties.
function image_process1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_process1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function image_process2_Callback(hObject, eventdata, handles)
% hObject    handle to image_process2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of image_process2 as text
%        str2double(get(hObject,'String')) returns contents of image_process2 as a double


% --- Executes during object creation, after setting all properties.


function image_process2_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in OrientationalOrderParameter.
function OrientationalOrderParameter_Callback(hObject, eventdata, handles)

global x_particle;
global y_particle;

orientationalorderparameter(x_particle,y_particle);


% --- Executes on button press in Calc_O2_PairC.
function Calc_O2_PairC_Callback(hObject, eventdata, handles)

global XY_Data;


q=g2ofrone2D(XY_Data);

figure
plot(q(:,1),q(:,5));

global P_C_Data;    
P_C_Data = [q(:,1) q(:,5)];


% --- Executes on button press in select_roi_area.
function select_roi_area_Callback(hObject, eventdata, handles)

global Z;
global img;

global x_min_original;
global x_max_original;
global y_min_original;
global y_max_original;

global x_min;
global x_max;
global y_min;
global y_max;

[x_mn, x_mx, y_mn, y_mx]=select_roi_points();
x_mn=round(x_mn);
x_mx=round(x_mx);
y_mn=round(y_mn);
y_mx=round(y_mx);


ZZ=Z(y_mn:y_mx,x_mn:x_mx);

hold on;
imagesc(ZZ);
xlim([1 length(ZZ(1,:))]);
ylim([1 length(ZZ(:,1))]);


new_x_min=x_mn+x_min;
new_x_max=x_mx+x_min;
new_y_min=y_mn+y_min;
new_y_max=y_mx+y_min;


x_min=new_x_min;
x_max=new_x_max;
y_min=new_y_min;
y_max=new_y_max;

x_min_original=x_min;
y_min_original=y_min;
x_max_original=x_max;
y_max_original=y_max;


Z=ZZ
img=Z;;
