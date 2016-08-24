%PTVlab - Digital Particle Tracking Velocimetry Tool for MATLAB
%{
May 03, 2012
developed by MSE. Antoine Patalano
with the algorithm of PhD. Brevis Wernher
graphical user interface from PIVlab v1.2 developed by (Dipl. Biol. William Thielicke and Prof. Dr. Eize J. Stamhuis)
programmed with MATLAB 7.7.0.471 (R2008b) Service Pack 3 (September 17, 2008)
available at http://www.mathworks.com/matlabcentral/fileexchange/27659-pivlab-time-resolved-particle-image-velocimetry-piv-tool
Copyright (c) 2009, W Thielicke
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE)ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%}

function varargout = PTVlab_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PTVlab_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @PTVlab_GUI_OutputFcn, ...
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

function PTVlab_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
%The opening function contains code that is executed just before the GUI is made visible to the user. You can access all the components for the GUI in the opening function, because all objects in the GUI are created before the opening function is called. You can add code to the opening function to perform tasks that need to be done before the user has access to the GUI -- for example,
% It is executed just before the GUI is made visible to the user, but after
% all the components have been created, i.e., after the components' CreateFcn callbacks, if any, have been run.
handles.output = hObject;
guidata(hObject, handles);
handles=guihandles(hObject);
setappdata(0,'hgui',gcf);
clc
try
    result=license('checkout','Image_Toolbox');
    if result == 1
        disp('-> Image Processing Toolbox found.')
    else
        disp('ERROR: Image Processing Toolbox not found! PTVlab won''t work like this.')
    end
    if exist ('PTVlab_GUI.fig')==2 && exist ('dctn.m')==2 && exist ('idctn.m')==2 && exist ('inpaint_nans.m')==2 ...
            && exist ('PTVlab_detection.m')==2 && exist ('PTVlablogo.jpg')==2 && exist ('smoothn.m')==2 ...
            && exist ('uipickfiles.m')==2 && exist ('PTVlab_settings_default.mat')==2 && exist ('hsbmap.mat')==2 ...
            && exist ('rainbow.mat')==2 && exist ('ellipse.m')==2 && exist ('nanmax.m')==2 && exist ('nanmin.m')==2 ...
            && exist ('nanstd.m')==2 && exist ('nanmean.m')==2 && exist ('exportfig.m')==2 && exist('filtercc.m')==2 ...
            && exist('filterrm.m')==2 && exist('gaussdetection.m')==2 && exist('lagrangeanpathccrm.m')==2 ...
            && exist('maxindomain.m')==2 && exist('nan.m')==2 && exist('ptv_CCRM.m')==2 && exist('relaxationmatching.m')==2 ...
            && exist('ncluster.m')==2 && exist('ptv2grid.m')==2 && exist('PTVlab_commandline.m')==2 ...
            && exist('inpoly.m')==2 && exist('dynadetection.m')==2 && exist('compute_homography.m')==2
        disp('-> Required additional files found.')
    else
        disp('ERROR: Some required files could not be found. Current directory has to be the PTVlab folder!')
    end
catch
    result=0;
    disp('Toolboxes could not be checked automatically. You need the Image Processing Toolbox')
end
set (hObject, 'position', [329.25 148.5 605 465]); %standard size in points
drawnow;
movegui(hObject,'center')
%Variable initialization
put('PTVver', 'Beta');
put ('toggler',0);
put('caluv',1);
put('calxy',1);
put('time',1);
put('subtr_u', 0);
put('subtr_v', 0);
put('displaywhat',1);%vectors
put('imgproctoolbox',result);
if result==1
    msg={'Welcome to PTVlab!';...
        ['version: ' retr('PTVver')];...
        '';...
        'Start by selecting';...
        '"File" -> "New session"';...
        'from the menu. Load';...
        'your PTV images by';...
        'clicking "Load images" on the';...
        'right hand side.';...
        '';...
        'Then, work your way through';...
        'the menu from left to right.';...
        };
else
    msg={'!!! WARNING !!! The Image Processing toolbox was not detected on your system. PTVlab will most likely not work like this. You definetively need this toolbox to run PTVlab!'};
end
set(handles.text6,'String', msg);
%read current and last directory.....:
try
    lastdir=importdata('last.nf','\t');
    put('homedir',lastdir{1});
    put('pathname',lastdir{2});
catch
    try
        lastdir{1}=pwd;
        lastdir{2}=pwd;
        dlmwrite('last.nf', lastdir{1}, 'delimiter', '', 'precision', 6, 'newline', 'pc')
        dlmwrite('last.nf', lastdir{2}, '-append', 'delimiter', '', 'precision', 6, 'newline', 'pc')
        put('pathname',lastdir{2});
    catch
    end
end

try
    read_settings ('PTVlab_settings_default.mat',pwd);
catch
%     disp('Error loading default settings. Please always start PTVlab_GUI from it''s folder.')
end

load iconmov2ima.mat
set(handles.loadmovbutton, 'cdata',Icon);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

function varargout = PTVlab_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
displogo(1)

function displogo(zoom)
logoimg=imread('ptvlablogo.jpg');
if zoom==1
    h=image(logoimg+255, 'parent', gca);
    axis image;
    set(gca,'ytick',[])
    set(gca,'xtick',[])
    set(gca, 'xlim', [1 size(logoimg,2)]);
    set(gca, 'ylim', [1 size(logoimg,1)]);
    set(gca, 'ydir', 'reverse');
    for i=255:-10:0
        RGB2=logoimg+i;
        try
            set (h, 'cdata', RGB2);
        catch
            disp('.')
        end
        drawnow expose;
    end
end
%get(gca,'position')
image(logoimg, 'parent', gca);

axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
set(gca, 'xlim', [1 size(logoimg,2)]);
set(gca, 'ylim', [1 size(logoimg,1)]);

set(gca, 'ydir', 'reverse');
text (290,500,['version: ' retr('PTVver')], 'fontsize', 7);
imgproctoolbox=retr('imgproctoolbox');
put('imgproctoolbox',[]);
if imgproctoolbox==0
    text (90,200,'Image processing toolbox not found!', 'fontsize', 16, 'color', [1 0 0], 'backgroundcolor', [0 0 0]);
end

function switchui (who)
handles=guihandles(getappdata(0,'hgui'));
turnoff=findobj('-regexp','Tag','multip');
set(turnoff, 'visible', 'off');
turnon=findobj('-regexp','Tag',who);
set(turnon, 'visible', 'on');
drawnow;

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);

function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);

function handles=gethand
hgui=getappdata(0,'hgui');
handles=guihandles(hgui);

function sliderdisp
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
filepath=retr('filepath');
pathname=retr('pathname');
%some graphic cards doesn'y work well with openGL (transparent NaN)
gl = opengl('data');
if strfind(gl.Vendor,'ATI')
    opengl('software')
end

%if the images are not found on the current path, then let user choose new path
%not found: assign new path to all following elements.
%check next file. not found -> assign new path to all following.
%and so on...
%checking if all files exist takes 0.5 s each time... need for optimization
%e.g. do this only one time at the start.
if   get(handles.orthotrans,'Value')==0   
if isempty(filepath) == 0 && exist(filepath{selected},'file') ~=2
    for i=1:size(filepath,1)
        while exist(filepath{i,1},'file') ~=2
            errordlg(['The image ' sprintf('\n') filepath{i,1} sprintf('\n') '(and probably some more...) could not be found.' sprintf('\n') 'Please select the path where the images are located.'],'File not found!','on')
            uiwait
            new_dir = uigetdir(pwd,'Please specify the path to all the images');
            for j=i:size(filepath,1) %apply new path to all following imgs.
                if ispc==1
                    zeichen=findstr('\',filepath{j,1});
                else
                    zeichen=findstr('/',filepath{j,1});
                end
                currentobject=filepath{j,1};
                currentpath=currentobject(1:(zeichen(1,size(zeichen,2))));
                currentfile=currentobject(zeichen(1,size(zeichen,2))+1:end);
                if ispc==1
                    filepath{j,1}=[new_dir '\' currentfile];
                else
                    filepath{j,1}=[new_dir '/' currentfile];
                end
            end
            put('filepath',filepath);
            
            if ispc==1
                PathName=[new_dir '\' ];
            else
                PathName=[new_dir '/' ];
            end
            put('PathName',PathName)
            
        end
    end
end
end

currentframe=2*floor(get(handles.fileselector, 'value'))-1;
%display derivatives if available and desired...
displaywhat=retr('displaywhat');
delete(findobj('tag', 'derivhint'));
delete(findobj('tag', 'arrowsptv'));
delete(findobj('tag', 'arrowsgrid'));
% delete(findobj(gca,'tag', 'roiplot'));
% delete(findobj(gca,'tag', 'roitext'));

if size(filepath,1)>0
    if get(handles.orthotrans,'Value')==0
        derived=retr('derived');
        if isempty(derived)==0   %derivatives were calculated
            %derived=retr('derived');
            %1=vectors only
            if displaywhat==1 %vectors only
                currentimage=imread(filepath{selected});
                image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
                colormap('gray');
                vectorcolor='g';
                
                %end
            else %displaywhat>1
                if size(derived,2)>=(currentframe+1)/2 && numel(derived{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
                    
                    currentimage=derived{displaywhat-1,(currentframe+1)/2};
                    
                    %is currentimage 3d? That would cause problems.-....
                    %                 hold on
                    
                    %                aks=axes
                    %                 set(gca, 'Color', 'none')
                    h=image(rescale_maps(currentimage), 'parent',gca, 'cdatamapping', 'scaled');
                    alpha=double(~isnan(rescale_maps(currentimage)));
                    set(h, 'AlphaData', alpha);
                    %                 hold off
                    
                    
                    
                    
                    %                 image(rescale_maps(currentimage), 'parent',gca, 'cdatamapping', 'scaled','AlphaData',bip);
                    avail_maps=get(handles.colormap_choice,'string');
                    selected_index=get(handles.colormap_choice,'value');
                    if selected_index == 4 %HochschuleBremen map
                        load hsbmap.mat;
                        colormap(hsb);
                    elseif selected_index== 1 %rainbow
                        load rainbow.mat;
                        colormap (rainbow);
                    else
                        colormap(avail_maps{selected_index});
                    end
                    if get(handles.autoscaler,'value')==1
                        minscale=min(min(currentimage));
                        maxscale=max(max(currentimage));
                        set (handles.mapscale_min, 'string', num2str(minscale))
                        set (handles.mapscale_max, 'string', num2str(maxscale))
                    else
                        minscale=str2double(get(handles.mapscale_min, 'string'));
                        maxscale=str2double(get(handles.mapscale_max, 'string'));
                    end
                    caxis([minscale maxscale])
                    vectorcolor='k';
                    if get(handles.displ_colorbar,'value')==1
                        colorbar ('South','FontWeight','bold');
                    end
                else %no deriv available
                    currentimage=imread(filepath{selected});
                    image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
                    colormap('gray');
                    vectorcolor='g';
                    text(10,10,'This parameter needs to be calculated for this frame first. Go to Plot -> Derive Parameters and click "Apply to current frame".','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'derivhint')
                end
            end
        else %not in derivatives panel
            currentimage=imread(filepath{selected});
            %         currentimage=imread(filepath{selected});
            image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
            colormap('gray');
            vectorcolor='g';
        end
        
        
        
        
        
    elseif   get(handles.orthotrans,'Value')==1        
        derivedRW=retr('derivedRW');
        if isempty(derivedRW)==0   %derivatives were calculated
            %derived=retr('derived');
            %1=vectors only
            if displaywhat==1 %vectors only                
                    currentimage=imread([ retr('PathName') '\Rectified_MEAN.jpg']);                
                image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
                colormap('gray');
                vectorcolor='g';
                
                %end
            else %displaywhat>1
                if size(derivedRW,2)>=(currentframe+1)/2 && numel(derivedRW{displaywhat-1,(currentframe+1)/2})>0 %derived parameters requested and existant
                      currentimage=derivedRW{displaywhat-1,(currentframe+1)/2};
                    
                    %is currentimage 3d? That would cause problems.-....
                    %                 hold on
                    
                    %                aks=axes
                    %                 set(gca, 'Color', 'none')
                    h=image(rescale_maps(currentimage), 'parent',gca, 'cdatamapping', 'scaled');
                    alpha=double(~isnan(rescale_maps(currentimage)));
                    set(h, 'AlphaData', alpha);
                    %                 hold off
                    
                    
                    
                    
                    %                 image(rescale_maps(currentimage), 'parent',gca, 'cdatamapping', 'scaled','AlphaData',bip);
                    avail_maps=get(handles.colormap_choice,'string');
                    selected_index=get(handles.colormap_choice,'value');
                    if selected_index == 4 %HochschuleBremen map
                        load hsbmap.mat;
                        colormap(hsb);
                    elseif selected_index== 1 %rainbow
                        load rainbow.mat;
                        colormap (rainbow);
                    else
                        colormap(avail_maps{selected_index});
                    end
                    if get(handles.autoscaler,'value')==1
                        minscale=min(min(currentimage));
                        maxscale=max(max(currentimage));
                        set (handles.mapscale_min, 'string', num2str(minscale))
                        set (handles.mapscale_max, 'string', num2str(maxscale))
                    else
                        minscale=str2double(get(handles.mapscale_min, 'string'));
                        maxscale=str2double(get(handles.mapscale_max, 'string'));
                    end
                    caxis([minscale maxscale])
                    vectorcolor='k';
                    if get(handles.displ_colorbar,'value')==1
                        colorbar ('South','FontWeight','bold');
                    end
                else %no deriv available
                    currentimage=imread([pathname '\Rectified_MEAN.jpg']);
                    image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
                    colormap('gray');
                    vectorcolor='g';
                    text(10,10,'This parameter needs to be calculated for this frame first. Go to Plot -> Derive Parameters and click "Apply to current frame".','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'derivhint')
                end
            end
        else %not in derivatives panel            
                currentimage=imread([retr('PathName') 'Rectified_MEAN.jpg']);            
            %         currentimage=imread(filepath{selected});
            image(currentimage, 'parent',gca, 'cdatamapping', 'scaled');
            colormap('gray');
            vectorcolor='g';
        end
    end
    
    
    
    axis image;
    set(gca,'ytick',[])
    set(gca,'xtick',[])
    if get(handles.orthotrans,'Value')==1
        set(gca,'YDir','normal')
    end
    filename=retr('filename');
    set (handles.filenameshow, 'string', ['Frame (' int2str(floor(get(handles.fileselector, 'value'))) '/' int2str(size(filepath,1)/2) '):' sprintf('\n') filename{selected}]);
    set (handles.filenameshow, 'tooltipstring', filepath{selected});
    if strmatch(get(handles.multip01, 'visible'), 'on');
        set(handles.imsize, 'string', ['Image size: ' int2str(size(currentimage,2)) '*' int2str(size(currentimage,1)) 'px' ])
    end
    if get(handles.orthotrans,'Value')==0
        maskiererx=retr('maskiererx');
        maskierery=retr('maskierery');
        if size(maskiererx,2)>=currentframe
            ximask=maskiererx{1,currentframe};
            if size(ximask,1)>1
                if strmatch(get(handles.multip08, 'visible'), 'on')
                    if get(handles.img_not_mask, 'value')==1 && displaywhat>1
                    else
                        dispMASK
                    end
                else
                    dispMASK
                end
            end
        end
        roirect=retr('roirect');
        if size(roirect,2)>1
            dispROI
        end
    end
    resultslist=retr('resultslist');
    resultslistRW=retr('resultslistRW');
    resultslistptv=retr('resultslistptv');
    delete(findobj('tag', 'smoothhint'));
    ismean=retr('ismean');
    
    
    
    
    %here code to display PTVresults
    %     if size(resultslistptv,2)>=(currentframe+1)/2 && isempty(resultslistptv{1,(currentframe+1)/2})==0 ...
    %             && strcmp(get(handles.multip05, 'visible'),'on')==1 && get(handles.togglerealmesh,'value')==0
    
    if size(resultslistptv,2)>=(currentframe+1)/2 && isempty(resultslistptv{1,(currentframe+1)/2})==0 ...
            && get(handles.togglerealmesh,'value')==0
        
        x=resultslistptv{2,(currentframe+1)/2};
        y=resultslistptv{1,(currentframe+1)/2};
        %          u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
        %          v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
        typevector=resultslistptv{5,(currentframe+1)/2};
        
        
        if  get(handles.orthotrans,'Value')==0
            if size(resultslistptv,1)>6 %filtered exists
                if size(resultslistptv,1)>10 && numel(resultslistptv{10,(currentframe+1)/2}) > 0 %smoothed exists
                    u=resultslistptv{11,(currentframe+1)/2};
                    v=resultslistptv{10,(currentframe+1)/2};
                    typevector=resultslistptv{9,(currentframe+1)/2};
                    text(3,size(currentimage,1)-4, 'Smoothed dataset','tag', 'smoothhint', 'backgroundcolor', 'k', 'color', 'y','fontsize',6);
                    if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
                        typevector=resultslistptv{5,(currentframe+1)/2};
                    end
                else
                    u=resultslistptv{8,(currentframe+1)/2};
                    if size(u,1)>1
                        v=resultslistptv{7,(currentframe+1)/2};
                        typevector=resultslistptv{9,(currentframe+1)/2};
                    else %filter was applied for other frames but not for this one
                        u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
                        v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
                        typevector=resultslistptv{5,(currentframe+1)/2};
                    end
                end
            else
                u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
                v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
                typevector=resultslistptv{5,(currentframe+1)/2};
            end
            
        elseif get(handles.orthotrans,'Value')==1
            resultslistptvRW=retr('resultslistptvRW');
            u=resultslistptvRW{4,(currentframe+1)/2}-resultslistptvRW{2,(currentframe+1)/2};
            v=resultslistptvRW{3,(currentframe+1)/2}-resultslistptvRW{1,(currentframe+1)/2};
            x=resultslistptvRW{2,(currentframe+1)/2};
            y=resultslistptvRW{1,(currentframe+1)/2};
            typevector=resultslistptvRW{5,(currentframe+1)/2};
        end
        
        autoscale_vec=get(handles.autoscale_vec, 'Value');
        
        if autoscale_vec == 1
            autoscale=1;
            %from quiver autoscale function:
            if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
            delx = diff([min(x(:)) max(x(:))])/n;
            dely = diff([min(y(:)) max(y(:))])/m;
            del = delx.^2 + dely.^2;
            if del>0
                len = sqrt((u.^2 + v.^2)/del);
                maxlen = max(len(:));
            else
                maxlen = 0;
            end
            if maxlen>0
                autoscale = autoscale/ maxlen;
            else
                autoscale = autoscale;
            end
            vecscale=autoscale;
        else %autoscale off
            vecscale=str2num(get(handles.vectorscale,'string'));
        end
        
        hold on
        
        
        if get(handles.orthotrans,'Value')==1
            q3=scatter(x(typevector==1),y(typevector==1),'w.');
        end
        
        q=quiver(x(typevector==1),y(typevector==1),...
            (u(typevector==1)-(retr('subtr_u')/retr('caluv')))*vecscale,...
            (v(typevector==1)-(retr('subtr_v')/retr('caluv')))*vecscale, ...
            'Color','r','autoscale','on','linewidth', ...
            str2double(get(handles.vecwidth,'string')),'tag','arrowsptv'); %quiver(ximage1,ximage2,ximage2-ximage1,yimage2-yimage1)
        
        q2=quiver(x(typevector==2),y(typevector==2), ...
            (u(typevector==2)-(retr('subtr_u')/retr('caluv')))*vecscale,...
            (v(typevector==2)-(retr('subtr_v')/retr('caluv')))*vecscale, ...
            'Color', [1 0.5 0],'autoscale','on','linewidth'...
            ,str2double(get(handles.vecwidth,'string')));
        
        scatter(x(typevector==0),y(typevector==0),'rx') %masked
        set(q, 'ButtonDownFcn', @veclick, 'hittestarea', 'on');
        set(q2, 'ButtonDownFcn', @veclick, 'hittestarea', 'on');
    end
    hold off
    
    
    
    if (size(resultslist,2)>=(currentframe+1)/2 && isempty(resultslist{1,(currentframe+1)/2})==0 && get(handles.togglerealmesh,'value')==1 && get(handles.orthotrans,'Value')==0) ...
             || (size(resultslistRW,2)>=(currentframe+1)/2 && isempty(resultslistRW{1,(currentframe+1)/2})==0 && get(handles.togglerealmesh,'value')==1 && get(handles.orthotrans,'Value')==1) ...
             %Display the results on the MESH
        
        if get(handles.orthotrans,'Value')==0
            if ~any(ismean==1)==0 && (currentframe+1)/2==size(resultslist,2)% if average is calc
                deriv=get(handles.derivchoice, 'value');
                if deriv==3 || deriv==1
                    X=resultslist{1,end};
                    Y=resultslist{2,end};
                    U=resultslist{3,end};
                    V=resultslist{4,end};
                else
                    X=resultslist{1,end}*nan;
                    Y=X;
                    U=X;
                    V=X;
                    
                end
            else
                
                
                try
                    
                    
                    x=resultslistptv{2,(currentframe+1)/2};
                    y=resultslistptv{1,(currentframe+1)/2};
                    
                    
                    if size(resultslistptv,1)>6 %filtered exists
                        if size(resultslistptv,1)>10 && numel(resultslistptv{10,(currentframe+1)/2}) > 0 %smoothed exists
                            u=resultslistptv{11,(currentframe+1)/2};
                            v=resultslistptv{10,(currentframe+1)/2};
                            typevector=resultslistptv{9,(currentframe+1)/2};
                            text(3,size(currentimage,1)-4, 'Smoothed dataset','tag', 'smoothhint', 'backgroundcolor', 'k', 'color', 'y','fontsize',6);
                            if numel(typevector)==0 %happens if user smoothes sth without NaN and without validation
                                typevector=resultslistptv{5,(currentframe+1)/2};
                            end
                        else
                            u=resultslistptv{8,(currentframe+1)/2};
                            if size(u,1)>1
                                v=resultslistptv{7,(currentframe+1)/2};
                                typevector=resultslistptv{9,(currentframe+1)/2};
                            else %filter was applied for other frames but not for this one
                                u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
                                v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
                                typevector=resultslistptv{5,(currentframe+1)/2};
                            end
                        end
                    else
                        u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
                        v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
                        typevector=resultslistptv{5,(currentframe+1)/2};
                    end
                    
                    
                    
                    %make cluster of points. idx is the index of each cluster
                    RadiusCluster=80; %in pixel
                    idx=ncluster(x(typevector==1),y(typevector==1),RadiusCluster);
                    
                    %Give the matrix X, Y, U  V (can be improved)
                    
                    meshsize=10; %(in pixel)
                    
                    %                 meshsize=round(size(currentimage,2)/50);
                    
                    currentimage=imread(filepath{selected});
                    [X Y U V InMask] = ptv2grid(x(typevector==1),y(typevector==1),u(typevector==1),v(typevector==1)...
                        ,currentimage,roirect,meshsize,idx,maskiererx,maskierery);
                    
                    %save it in resultlist
%                     resultslist{1,(selected+1)/2}=X;
%                     resultslist{2,(selected+1)/2}=Y;
%                     resultslist{3,(selected+1)/2}=U;
%                     resultslist{4,(selected+1)/2}=V;
                    resultslist{1,(currentframe+1)/2}=X;
                    resultslist{2,(currentframe+1)/2}=Y;
                    resultslist{3,(currentframe+1)/2}=U;
                    resultslist{4,(currentframe+1)/2}=V;
                catch
                    if currentframe<=size(resultslistptv,2)*2
                        resultslist{1,(selected+1)/2}=[];
                        resultslist{2,(selected+1)/2}=[];
                        resultslist{3,(selected+1)/2}=[];
                        resultslist{4,(selected+1)/2}=[];
                    else %mean is calculated
                    end
                    
                end
                
                
                X=resultslist{1,(currentframe+1)/2};
                Y=resultslist{2,(currentframe+1)/2};
                U=resultslist{3,(currentframe+1)/2};
                V=resultslist{4,(currentframe+1)/2};
            end
            
            autoscale_vec=get(handles.autoscale_vec, 'Value');
            
            if autoscale_vec == 1
                autoscale=1;
                %from quiver autoscale function:
                if min(size(x))==1, n=sqrt(numel(x)); m=n; else [m,n]=size(x); end
                delx = diff([min(x(:)) max(x(:))])/n;
                dely = diff([min(y(:)) max(y(:))])/m;
                del = delx.^2 + dely.^2;
                if del>0
                    len = sqrt((u.^2 + v.^2)/del);
                    maxlen = max(len(:));
                else
                    maxlen = 0;
                end
                if maxlen>0
                    autoscale = autoscale/ maxlen;
                else
                    autoscale = autoscale;
                end
                vecscale=autoscale;
            else %autoscale off
                vecscale=str2num(get(handles.vectorscale,'string'));
            end
            
            hold on
            try
                InMask;
            catch
                InMask=U*0;
                for i=1:size(maskiererx,1)
                    if isempty(maskiererx{i,1})==0
                        p=[ reshape(X,size(X,1)*size(X,2),1),reshape(Y,size(Y,1)*size(Y,2),1)];
                        % make nan masked value
                        node=[maskiererx{i,1} maskierery{i,1}];
                        n      = size(node,1);
                        cnect  = [(1:n-1)' (2:n)'; n 1];
                        inside=inpoly(p,node,cnect);
                        InMask(inside==1)=1;
                        
                    end
                end
            end
            
            q1=quiver(X(InMask==0),Y(InMask==0), ...
                U(InMask==0)-(retr('subtr_u')/retr('caluv'))* vecscale, ...
                V(InMask==0)-(retr('subtr_u')/retr('caluv'))* vecscale, ...
                vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'tag','arrowsgrid');
            q2=quiver(X(InMask==1),Y(InMask==1), ...
                U(InMask==1)-(retr('subtr_u')/retr('caluv'))* vecscale, ...
                V(InMask==1)-(retr('subtr_u')/retr('caluv'))* vecscale, ...
                'r','autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'tag','arrowsgrid');
            
            hold off
        elseif get(handles.orthotrans,'Value')==1
            resultslistRW=retr('resultslistRW');
            X=resultslistRW{1,(currentframe+1)/2};
            Y=resultslistRW{2,(currentframe+1)/2};
            U=resultslistRW{3,(currentframe+1)/2};
            V=resultslistRW{4,(currentframe+1)/2};
            hold on
            q1=quiver(X(isnan(U)==0),Y(isnan(U)==0), ...
                U(isnan(U)==0)-(retr('subtr_u')/retr('caluv')), ...
                V(isnan(U)==0)-(retr('subtr_u')/retr('caluv')), ...
                vectorcolor,'autoscale', 'off','linewidth',str2double(get(handles.vecwidth,'string')),'tag','arrowsgrid');
            hold off
            
        end
        
        %streamlines:
        streamlinesX=retr('streamlinesX');
        streamlinesY=retr('streamlinesY');
        delete(findobj('tag','streamline'));
        if numel(streamlinesX)>0
            ustream=u*retr('caluv')-retr('subtr_u');
            vstream=v*retr('caluv')-retr('subtr_v');
            ustream(typevector==0)=nan;
            vstream(typevector==0)=nan;
            h=streamline(stream2(x,y,ustream,vstream,streamlinesX,streamlinesY));
            set (h,'tag','streamline');
            contents = get(handles.streamlcolor,'String');
            set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
        end
        
        %manualmarkers
        if get(handles.displmarker,'value')==1
            manmarkersX=retr('manmarkersX');
            manmarkersY=retr('manmarkersY');
            delete(findobj('tag','manualmarker'));
            if numel(manmarkersX)>0
                hold on
                plot(manmarkersX,manmarkersY, 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
                hold off
            end
        end
        
        
        
        if strmatch(get(handles.multip14, 'visible'), 'on'); %statistics panel visible
            %             update_Stats (x,y,u,v);
        end
        if strmatch(get(handles.multip06, 'visible'), 'on'); %validation panel visible
            manualdeletion=retr('manualdeletion');
            frame=floor(get(handles.fileselector, 'value'));
            framemanualdeletion=[];
            if numel(manualdeletion)>0
                if size(manualdeletion,2)>=frame
                    if isempty(manualdeletion{1,frame}) ==0
                        framemanualdeletion=manualdeletion{frame};
                    end
                end
            end
            if isempty(framemanualdeletion)==0
                
                
                hold on;
                for i=1:size(framemanualdeletion,1)
                    scatter (x(framemanualdeletion(i,1),framemanualdeletion(i,2)),y(framemanualdeletion(i,1),framemanualdeletion(i,2)), 'rx', 'tag','manualdot')
                end
                hold off;
            end
        end
        
        %{
        figure;
        [Vx2,Vy2] = pppiv(u,v);
        quiver(Vx2,Vy2)
        %}
        
    end
    
    
    drawnow;
end

function update_Stats(x,y,u,v)
handles=gethand;
caluv=retr('caluv');
calxy=retr('calxy');
x=reshape(x,size(x,1)*size(x,2),1);
y=reshape(y,size(y,1)*size(y,2),1);
u=reshape(u,size(u,1)*size(u,2),1);
v=reshape(v,size(v,1)*size(v,2),1);
set (handles.meanu,'string', [num2str(nanmean(u*caluv)) ' ± ' num2str(nanstd(u*caluv))])
set (handles.meanv,'string', [num2str(nanmean(v*caluv)) ' ± ' num2str(nanstd(v*caluv))])

function veclick(src,eventdata)
%only active if vectors are displayed.
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
resultslist=retr('resultslist');
x=resultslist{1,(currentframe+1)/2};
y=resultslist{2,(currentframe+1)/2};
pos=get(gca,'CurrentPoint');
xposition=round(pos(1,1));
yposition=round(pos(1,2));
findx=abs(x/xposition-1);
[trash, imagex]=find(findx==min(min(findx)));
findy=abs(y/yposition-1);
[imagey, trash]=find(findy==min(min(findy)));
info(1,1)=imagey(1,1);
info(1,2)=imagex(1,1);
%LOAD INTERPOLATED RESULT IF EXISTENT
if size(resultslist,1)>6 %filtered exists
    u=resultslist{7,(currentframe+1)/2};
    typevector=resultslist{5,(currentframe+1)/2};
    if numel(u)>0
        v=resultslist{8,(currentframe+1)/2};
    else
        u=resultslist{3,(currentframe+1)/2};
        v=resultslist{4,(currentframe+1)/2};
    end
else
    u=resultslist{3,(currentframe+1)/2};
    v=resultslist{4,(currentframe+1)/2};
    
    typevector=resultslist{5,(currentframe+1)/2};
end
if typevector(info(1,1),info(1,2)) ~=0
    delete(findobj('tag', 'infopoint'));
    %here, the calibration matters...
    set(handles.u_cp, 'String', ['u:' num2str(round((u(info(1,1),info(1,2))*retr('caluv')-retr('subtr_u'))*1000)/1000)]);
    set(handles.v_cp, 'String', ['v:' num2str(round((v(info(1,1),info(1,2))*retr('caluv')-retr('subtr_v'))*1000)/1000)]);
    derived=retr('derived');
    displaywhat=retr('displaywhat');
    if displaywhat>1
        if size (derived,2) >= (currentframe+1)/2
            if numel(derived{displaywhat-1,(currentframe+1)/2})>0
                map=derived{displaywhat-1,(currentframe+1)/2};
                name=get(handles.derivchoice,'string');
                set(handles.scalar_cp, 'String', [name{displaywhat} ': ' num2str(round(map(info(1,1),info(1,2))*1000)/1000)]);
            else
                set(handles.scalar_cp, 'String','N/A');
            end
        else
            set(handles.scalar_cp, 'String','N/A');
        end
    else
        set(handles.scalar_cp, 'String','N/A');
    end
    hold on;
    plot(x(info(1,1),info(1,2)),y(info(1,1),info(1,2)), 'yo', 'tag', 'infopoint','linewidth', 2, 'markersize', 10);
    hold off;
end

function toolsavailable(inpt);
%0: disable all tools
%1: re-enable tools that were previously also enabled
hgui=getappdata(0,'hgui');
elementsOfCrime=findobj(hgui, 'type', 'uicontrol');
elementsOfCrime2=findobj(hgui, 'type', 'uimenu');
statuscell=get (elementsOfCrime, 'enable');
wasdisabled=zeros(size(statuscell),'uint8');
handles=gethand;
if inpt==0
    set(elementsOfCrime, 'enable', 'off');
    for i=1:size(statuscell,1)
        if strmatch(statuscell{i,1}, 'off') ==1
            wasdisabled(i)=1;
        end
    end
    put('wasdisabled', wasdisabled);
    set(elementsOfCrime2, 'enable', 'off');
else
    wasdisabled=retr('wasdisabled');
    set(elementsOfCrime, 'enable', 'on');
    set(elementsOfCrime(wasdisabled==1), 'enable', 'off');
    set(elementsOfCrime2, 'enable', 'on');
end
set(handles.progress, 'enable', 'on');
set(handles.overall, 'enable', 'on');
set(handles.totaltime, 'enable', 'on');
set(handles.messagetext, 'enable', 'on');

function overlappercent
handles=gethand;
perc=100-str2double(get(handles.step,'string'))/str2double(get(handles.intarea,'string'))*100;
set (handles.steppercentage, 'string', ['= ' int2str(perc) '%']);

function figure1_ResizeFcn(hObject, eventdata, handles)
Figure_Size = get(hObject, 'Position');
%{
minimalwidth=801;
minimalheight=610;
panelwidth=188;
panelheight=484;
toolheight=120;
%}

%in points
minimalwidth=605;
minimalheight=450;
panelwidth=141;
panelheight=363;
toolheight=90;

if  Figure_Size(4)<minimalheight
    try
        set(hObject,'position', [Figure_Size(1) Figure_Size(2) Figure_Size(3) minimalheight+3]);
    catch
    end
end

handles=guihandles(hObject);
try
    %set (findobj('-regexp','Tag','multip'), 'position', [Figure_Size(3)-panelwidth Figure_Size(4)-panelheight-5 panelwidth panelheight]);
    set (findobj('-regexp','Tag','multip'), 'position', [Figure_Size(3)-panelwidth Figure_Size(4)-panelheight-3.75 panelwidth panelheight]);
    set (handles.tools, 'position', [Figure_Size(3)-panelwidth Figure_Size(4)-panelheight-toolheight panelwidth toolheight]);
    
    %set (gca, 'position', [5 5 Figure_Size(3)-198 Figure_Size(4)-10]);
    set (gca, 'position', [3.75 3.75 Figure_Size(3)-148.5 Figure_Size(4)-7.5]);
catch
end

function loadimgsbutton_Callback(hObject, eventdata, handles)
if ispc==1
    pathname=[retr('pathname') '\'];
else
    pathname=[retr('pathname') '/'];
end
displogo(0)
if ispc==1
    path=uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.tif$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
else
    path=uipickfiles ('FilterSpec', pathname, 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
end
if isequal(path,0) ==0
    sequencer=retr('sequencer');
    if sequencer==1
        for i=1:size(path,1)
            if path(i).isdir == 0 %remove directories from selection
                if exist('filepath','var')==0 %first loop
                    filepath{1,1}=path(i).name;
                else
                    filepath{size(filepath,1)+1,1}=path(i).name;
                end
            end
        end
    else %sequencer=0
        for i=1:size(path,1)
            if path(i).isdir == 0 %remove directories from selection
                if exist('filepath','var')==0 %first loop
                    filepath{1,1}=path(i).name;
                else
                    filepath{size(filepath,1)+1,1}=path(i).name;
                    filepath{size(filepath,1)+1,1}=path(i).name;
                end
            end
        end
    end
    if size(filepath,1) > 1
        if mod(size(filepath,1),2)==1
            cutoff=size(filepath,1);
            filepath(cutoff)=[];
        end
        filename=cell(1);
        for i=1:size(filepath,1)
            if ispc==1
                zeichen=findstr('\', filepath{i,1});
            else
                zeichen=findstr('/', filepath{i,1});
            end
            currentpath=filepath{i,1};
            if mod(i,2) == 1
                filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
            else
                filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
            end
        end
        %extract path:
        pathname=currentpath(1:zeichen(1,size(zeichen,2))-1);
        put('pathname',pathname); %last path
        put ('filename',filename); %only for displaying
        put ('filepath',filepath); %full path and filename for analyses
        handles=gethand;
        sliderrange
        set (handles.filenamebox, 'string', filename);
        put ('resultslist', []); %clears old results
        put ('derived',[]);
        put('displaywhat',1);%vectors
        put('ismean',[]);
        put('framemanualdeletion',[]);
        put('manualpoint',[]);
        put('manualdeletion',[]);
        put('streamlinesX',[]);
        put('streamlinesY',[]);
        set(handles.fileselector, 'value',1);
        %Clear all things
        clear_vel_limit_Callback %clear velocity limits
        clear_roi_Callback
        clear_mask_Callback
        %clear_cali_Callback do not clear calibration anymore.....
        %Problems...?
        sliderdisp %displays raw image when slider moves
        set(handles.skipper, 'enable', 'on');
        set(handles.applyskipper, 'enable', 'on');
    else
        errordlg('Please select at least two images ( = 1 pair of images)','Error','on')
    end
    
    %     save pathname pathname % added by antoine 06/04/2012
    
end

function loadmovbutton_Callback(hObject, eventdata, handles)

[FileName,PathName,FilterIndex] = uigetfile('*.avi','Select the movie to transform');
uimakevideo(PathName,FileName)
% info=aviinfo([PathName FileName]);


function sliderrange
filepath=retr('filepath');
handles=gethand;
if size(filepath,1)>2
    sliderstepcount=size(filepath,1)/2;
    set(handles.fileselector, 'enable', 'on');
    set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
else
    sliderstepcount=1;
    set(handles.fileselector, 'enable', 'off');
    set (handles.fileselector,'value',1, 'min', 1,'max',2,'sliderstep', [0.5 0.5]);
end

function fileselector_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
if size(filepath,1) > 1
    sliderdisp
end

function togglepair_Callback(hObject, eventdata, handles)
toggler=get(gco, 'value');
put ('toggler',toggler);
filepath=retr('filepath');
if size(filepath,1) > 1
    sliderdisp
end

function togglerealmesh_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
if size(filepath,1) > 1
    sliderdisp
end


function loadimgs_Callback(hObject, eventdata, handles)
switchui('multip01')

function img_mask_Callback(hObject, eventdata, handles)
switchui('multip02')

function pre_proc_Callback(hObject, eventdata, handles)
switchui('multip03')

function ptv_sett_Callback(hObject, eventdata, handles)
switchui('multip42')
pause(0.01) %otherwise display isn't updated... ?!?
drawnow;drawnow;
handles=gethand;
if get(handles.det_area,'Value')==1   & get(handles.rm,'Value')==0
    dispareacc
end
% dispinterrog
% countparticles
% overlappercent


function par_detec_Callback(hObject, eventdata, handles) %added by antoine 08/04/2012
switchui('multip41')
%






function do_analys_Callback(hObject, eventdata, handles)
handles=gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
switchui('multip05')

function vector_val_Callback(hObject, eventdata, handles)
handles=gethand;
set(handles.togglerealmesh,'value',0);




sliderdisp
switchui('multip06')

function cal_actual_Callback(hObject, eventdata, handles)
switchui('multip07')
pointscali=retr('pointscali');
if numel(pointscali>0)
    xposition=pointscali(:,1);
    yposition=pointscali(:,2);
    caliimg=retr('caliimg');
    if numel(caliimg)>0
        image(caliimg, 'parent',gca, 'cdatamapping', 'scaled');
        colormap('gray');
        axis image;
        set(gca,'ytick',[])
        set(gca,'xtick',[])
    else
        sliderdisp
    end
    hold on;
    plot (xposition,yposition,'ro-', 'markersize', 15,'LineWidth',3 , 'tag', 'caliline');
    plot (xposition,yposition,'y+:', 'tag', 'caliline');
    hold off;
    for j=1:2
        text(xposition(j)+10,yposition(j)+10, ['x:' num2str(xposition(j)) sprintf('\n') 'y:' num2str(yposition(j)) ],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'caliline')
    end
end

function plot_derivs_Callback(hObject, eventdata, handles)
handles=gethand;
set(handles.togglerealmesh,'value',1);
switchui('multip08');

function modif_plot_Callback(hObject, eventdata, handles)
switchui('multip09');

function ascii_chart_Callback(hObject, eventdata, handles)
switchui('multip10')

function matlab_file_Callback(hObject, eventdata, handles)
switchui('multip11')

function poly_extract_Callback(hObject, eventdata, handles)
switchui('multip12')

function dist_angle_Callback(hObject, eventdata, handles)
switchui('multip13')

function statistics_Callback(hObject, eventdata, handles)
switchui('multip14')
filepath=retr('filepath');
if size(filepath,1) > 1
    sliderdisp
end

function part_img_sett_Callback(hObject, eventdata, handles)
switchui('multip15')

function save_movie_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
if size(resultslist,2)>=2
    startframe=0;
    endframe=0
    for i=1:size(resultslist,2)
        if numel(resultslist{1,i})>0 && startframe==0
            startframe=i;
        end
        if numel(resultslist{1,i})>0
            endframe=i;
        end
    end
    set(handles.firstframe, 'String',int2str(startframe));
    set(handles.lastframe, 'String',int2str(endframe));
    if strmatch(get(handles.multip08, 'visible'), 'on');
        put('p8wasvisible',1)
    else
        put('p8wasvisible',0)
    end
    switchui('multip16');
else
    msgbox('There are not enough results to make a movie...')
end

function area_extract_Callback(hObject, eventdata, handles)
switchui('multip17');

function point_extract_Callback(hObject, eventdata, handles)
switchui('multip19');


function scatterplotter_Callback(hObject, eventdata, handles)

%if analys existing
resultslist=retr('resultslist');
resultslistptv=retr('resultslistptv');
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
    x=resultslistptv{2,(currentframe+1)/2};
    y=resultslistptv{1,(currentframe+1)/2};
    
    if size(x,1)>1
        %         if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
        for i=1:size(resultslistptv,2)
            if isempty(resultslistptv{1,i})==1
                alllength(i)=0;
            else
                alllength(i)=length(resultslistptv{1,i});
            end
        end
        maxlength=nanmax(alllength);
        for i=1:size(resultslistptv,2)
            u(:,i)=[resultslistptv{4,i}-resultslistptv{2,i}; nan*ones(maxlength-alllength(i),1)];
            v(:,i)=[resultslistptv{3,i}-resultslistptv{1,i}; nan*ones(maxlength-alllength(i),1)];%
        end
        
        velrect=retr('velrect');
        caluv=retr('caluv');
        if numel(velrect>0)
            %user already selected window before...
            %"filter u+v" and display scatterplot
            %problem: if user selects limits and then wants to refine vel
            %limits, all data is filterd out...
            umin=velrect(1);
            umax=velrect(3)+umin;
            vmin=velrect(2);
            vmax=velrect(4)+vmin;
            %             %check if all results are nan...
            %
            u_backup=u;
            v_backup=v;
            u(u*caluv<umin)=NaN;
            u(u*caluv>umax)=NaN;
            v(u*caluv<umin)=NaN;
            v(u*caluv>umax)=NaN;
            v(v*caluv<vmin)=NaN;
            v(v*caluv>vmax)=NaN;
            u(v*caluv<vmin)=NaN;
            u(v*caluv>vmax)=NaN;
            
        end
        datau=reshape(u*caluv,1,size(u,1)*size(u,2));
        datav=reshape(v*caluv,1,size(v,1)*size(v,2));
        h=figure;
        scatter(datau,datav, 'b.');
        xlabel(gca, 'u velocity', 'fontsize', 12)
        ylabel(gca, 'v velocity', 'fontsize', 12)
        grid on
        %axis equal;
        set (gca, 'tickdir', 'in');
        rangeu=nanmax(nanmax(u*caluv))-nanmin(nanmin(u*caluv));
        rangev=nanmax(nanmax(v*caluv))-nanmin(nanmin(v*caluv));
        set(gca,'xlim',[nanmin(nanmin(u*caluv))-rangeu*0.15 nanmax(nanmax(u*caluv))+rangeu*0.15])
        set(gca,'ylim',[nanmin(nanmin(v*caluv))-rangev*0.15 nanmax(nanmax(v*caluv))+rangev*0.15])
        
    end
end


% resultslistptv=retr('resultslistptv');
% if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
%     if size(resultslist,1)>6 %filtered exists
%         if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
%             u=resultslist{10,currentframe};
%             v=resultslist{11,currentframe};
%         else
%             u=resultslist{7,currentframe};
%             if size(u,1)>1
%                 v=resultslist{8,currentframe};
%             else
%                 %filter was applied to some other frame than this
%                 %load unfiltered results
%                 u=resultslist{3,currentframe};
%                 v=resultslist{4,currentframe};
%             end
%         end
%     else
%         u=resultslist{3,currentframe};
%         v=resultslist{4,currentframe};
%     end
%         caluv=retr('caluv');
%         u=reshape(u,size(u,1)*size(u,2),1);
%         v=reshape(v,size(v,1)*size(v,2),1);
%         h=figure;
%         screensize=get( 0, 'ScreenSize' );
%     rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
%     set(h,'position', rect);
%     set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Scatter plot u & v, frame ' num2str(currentframe)],'tag', 'derivplotwindow');
%     h2=scatter(u*caluv-retr('subtr_u'),v*caluv-retr('subtr_v'),'r.');
%     set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
%     xlabel('u');
%     ylabel('v');
% end

function plottrajectories_Callback(hObject, eventdata, handles)
handles=gethand;
toolsavailable(0)
delete(findobj('tag', 'trajectories'));
if get(handles.orthotrans,'Value')==0
    TrackID=retr('TrackID');
    resultslistptv=retr('resultslistptv');
elseif get(handles.orthotrans,'Value')==1
    TrackID=retr('TrackID');
    resultslistptv=retr('resultslistptvRW');
end
if isempty(TrackID)==1
    TrackID=lagranpath(resultslistptv);
    put('TrackID',TrackID);
end
hold on
numID=max(cell2mat(resultslistptv(6,end)));%gives the number of ID
text(10,10,'This might takes a few seconds to display the trajectories, please wait ....','color','r','fontsize',9, 'BackgroundColor', 'k', 'tag', 'trajhint')
drawnow
for i=1:numID
    plot(TrackID(i,1).col,TrackID(i,1).row,'Color',rand(1, 3),'LineWidth',2,'tag','trajectories');%plot all the trajectories
end
delete(findobj('tag', 'trajhint'));
hold off
toolsavailable(1)




function curr_fig_Callback(hObject, eventdata, handles)

imgsavepath=retr('imgsavepath');
if isempty(imgsavepath)
    imgsavepath=retr('pathname');
end
[filename, pathname] = uiputfile({ '*.bmp','Bitmap (*.bmp)'}, 'Save picture as',fullfile(imgsavepath,'PTVlab_out'));
if isequal(filename,0) || isequal(pathname,0)
    return
end
put('imgsavepath',pathname );
handles=gethand;
hgca=gca;
colo=get(gcf, 'colormap');
axes_units = get(hgca,'Units');
axes_pos = get(hgca,'Position');
aspect=axes_pos(3)/axes_pos(4);
newFig=figure;
set(newFig,'visible', 'off');
set(newFig,'Units',axes_units);
set(newFig,'Position',[15 5 axes_pos(3)+30 axes_pos(4)+10]);
axesObject2=copyobj(hgca,newFig);
set(axesObject2,'Units',axes_units);
set(axesObject2,'Position',[15 5 axes_pos(3) axes_pos(4)]);
colormap(colo);
if get(handles.displ_colorbar,'value')==1
    colorbar ('South','FontWeight','bold');
end
reso=inputdlg(['Please enter scale factor' sprintf('\n') '(1 = render image at same size as currently displayed)'],'Specify resolution',1,{'1'});
[reso status] = str2num(reso{1});  % Use curly bracket for subscript
if ~status
    reso=1;
end
exportfig(newFig,fullfile(pathname,filename),'height',3,'color','rgb','format','bmp','resolution',96*reso,'FontMode', 'scaled');
close(newFig)
autocrop(fullfile(pathname,filename),2);

function autocrop (file,fmt)
A=imread(file);
B=rgb2gray(A);
for i=1:ceil(size(B,1)/2)
    val(i)=mean(B(i,:));
end
startcropy=max(find(val==255));
for i=size(B,1):-1:ceil(size(B,1)/2)
    val2(i)=mean(B(i,:));
end

endcropy=min(find(val2==255));
clear val val2
for i=1:ceil(size(B,2)/2)
    val(i)=mean(B(:,i));
end
startcropx=max(find(val==255));
for i=size(B,2):-1:ceil(size(B,2)/2)
    val2(i)=mean(B(:,i));
end
endcropx=min(find(val2==255));
A=A(startcropy:endcropy,startcropx:endcropx,:);
if fmt==1 %jpg
    imwrite(A,file,'quality', 100);
else
    imwrite(A,file);
end


function file_save (currentframe,FileName,PathName,type)
handles=gethand;
if get(handles.orthotrans,'Value')==0
    resultslist=retr('resultslist');
    resultslistptv=retr('resultslistptv');
    derived=retr('derived');
elseif get(handles.orthotrans,'Value')==1
    resultslist=retr('resultslistRW');
    resultslistptv=retr('resultslistptvRW');
    derived=retr('derivedRW');
end
filename=retr('filename');
caluv=retr('caluv');
calxy=retr('calxy');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    if size(resultslist,1)>6 %filtered exists
        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
            u=resultslist{10,currentframe};
            v=resultslist{11,currentframe};
            typevector=resultslist{9,currentframe};
            if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
                typevector=resultslist{5,currentframe};
            end
        else
            u=resultslist{7,currentframe};
            if size(u,1)>1
                v=resultslist{8,currentframe};
                typevector=resultslist{9,currentframe};
            else
                %filter was applied to some other frame than this
                %load unfiltered results
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
                typevector=resultslist{5,currentframe};
            end
        end
    else
        u=resultslist{3,currentframe};
        v=resultslist{4,currentframe};
        %         typevector=resultslist{5,currentframe};
    end
end
% u(typevector==0)=NaN;
% v(typevector==0)=NaN;

if type==1 %ascii file
    delimiter=get(handles.delimiter, 'value');
    if delimiter==1
        delimiter=',';
    elseif delimiter==2
        delimiter='\t';
    elseif delimiter==3
        delimiter=' ';
    end
    if get(handles.addfileinfo, 'value')==1
        header1=['PTVlab 2012 by Antoine.Patalano. , ASCII chart output - ' date];
        header2=['FRAME: ' int2str(currentframe) ', filenames: ' filename{currentframe*2-1} ' & ' filename{currentframe*2} ', conversion factor xy (px -> m/s): ' num2str(calxy) ', conversion factor uv (px/im.pair -> m/s): ' num2str(caluv)];
    else
        header1=[];
        header2=[];
    end
    if get(handles.add_header, 'value')==1
        if get(handles.export_vort, 'Value') == 1
            header3=['x' delimiter 'y' delimiter 'u' delimiter 'v' delimiter 'vorticity'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
        else
            header3=['x' delimiter 'y' delimiter 'u' delimiter 'v'];%delimiter 'magnitude[m/s]' delimiter 'divergence[1]' delimiter 'vorticity[1/s]' delimiter 'dcev[1]']
        end
    else
        header3=[];
    end
    if isempty(header1)==0
        fid = fopen(fullfile(PathName,FileName), 'w');
        fprintf(fid, [header1 '\r\n']);
        fclose(fid);
    end
    if isempty(header2)==0
        fid = fopen(fullfile(PathName,FileName), 'a');
        fprintf(fid, [header2 '\r\n']);
        fclose(fid);
    end
    if isempty(header3)==0
        fid = fopen(fullfile(PathName,FileName), 'a');
        fprintf(fid, [header3 '\r\n']);
        fclose(fid);
    end
    if get(handles.export_vort, 'Value') == 1
        derivative_calc(currentframe,2,1);
        derived=retr('derived');
        vort=derived{1,currentframe};
        wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv,size(u,1)*size(u,2),1) reshape(v*caluv,size(v,1)*size(v,2),1) reshape(vort,size(vort,1)*size(vort,2),1)];
    else
        wholeLOT=[reshape(x*calxy,size(x,1)*size(x,2),1) reshape(y*calxy,size(y,1)*size(y,2),1) reshape(u*caluv,size(u,1)*size(u,2),1) reshape(v*caluv,size(v,1)*size(v,2),1)];
    end
    dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', delimiter, 'precision', 10, 'newline', 'pc');
end %type==1
if type==2 %matlab file
    u=u*caluv;
    v=v*caluv;
    x=x*calxy;
    y=y*calxy;
    if get(handles.export_vort2, 'Value') == 1
        derivative_calc(currentframe,2,1);
        derived=retr('derived');
        vort=derived{1,currentframe};
        save(fullfile(PathName,FileName), 'u', 'v', 'x', 'y', 'typevector', 'calxy', 'caluv', 'vort');
    else
        save(fullfile(PathName,FileName), 'u', 'v', 'x', 'y', 'typevector', 'calxy', 'caluv');
    end
end
% --------------------------------------------------------------------
function roi_select_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1
    delete(findobj('tag','warning'));
    toolsavailable(0);
    toggler=retr('toggler');
    selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
    filepath=retr('filepath');
    roirect = round(getrect(gca));
    if roirect(1,3)~=0 && roirect(1,4)~=0
        imagesize(1)=size(imread(filepath{selected}),1);
        imagesize(2)=size(imread(filepath{selected}),2);
        if roirect(1)<1
            roirect(1)=1;
        end
        if roirect(2)<1
            roirect(2)=1;
        end
        if roirect(3)>imagesize(2)-roirect(1)
            roirect(3)=imagesize(2)-roirect(1);
        end
        if roirect(4)>imagesize(1)-roirect(2)
            roirect(4)=imagesize(1)-roirect(2);
        end
        put ('roirect',roirect);
        dispROI
        
        set(handles.roi_hint, 'String', 'ROI active' , 'backgroundcolor', [0.5 1 0.5]);
    else
        text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k','tag','warning');
    end
    toolsavailable(1);
end

% --- Executes on button press in clear_roi.
function clear_roi_Callback(hObject, eventdata, handles)
handles=gethand;
delete(findobj(gca,'tag', 'roiplot'));
delete(findobj(gca,'tag', 'roitext'));
delete(findobj('tag','warning'));
put ('roirect',[]);
set(handles.roi_hint, 'String', 'ROI inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);

function dispROI
roirect=retr('roirect');
x=[roirect(1)  roirect(1)+roirect(3) roirect(1)+roirect(3)  roirect(1)            roirect(1) ];
y=[roirect(2)  roirect(2)            roirect(2)+roirect(4)  roirect(2)+roirect(4) roirect(2) ];
delete(findobj(gca,'tag', 'roiplot'));
delete(findobj(gca,'tag', 'roitext'));
hold on;
roi=plot(x,y,'y:','tag', 'roiplot');
hold off;
text(x(1),y(1)-14,['ROI: x=' int2str(roirect(1)) ' y=' int2str(roirect(2)) ' w=' int2str(roirect(3)) ' h=' int2str(roirect(4))],'color','r','fontsize',7, 'BackgroundColor', 'k', 'tag', 'roitext')

function dispMASK
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
maskiererx=retr('maskiererx');
maskierery=retr('maskierery');
delete(findobj(gca,'tag', 'maskplot'));
hold on;
for j=1:size(maskiererx,1)
    if isempty(maskiererx{j,currentframe})==0
        ximask=maskiererx{j,currentframe};
        yimask=maskierery{j,currentframe};
        h=area(ximask,yimask,'facecolor', [0.3 0.1 0.1],'linestyle', 'none','tag','maskplot');
    else
        break;
    end
    %     hPatch1 = findobj(h, 'Type', 'patch');
    %     hold on
    %     hh1 = hatchfill(h, 'cross', -45, 20);
    %     set(hh1, 'Color', 'y')
    %
end
hold off;

function draw_mask_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1
    toolsavailable(0);
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    filepath=retr('filepath');
    amount=size(filepath,1);
    %currentframe and currentframe+1 =is a pair with identical mask.
    %maskiererx&y contains masks. 3rd dimension is frame nr.
    maskiererx=retr('maskiererx');
    maskierery=retr('maskierery');
    [mask,ximask,yimask]=roipoly;
    insertion=1;
    for j=size(maskiererx,1):-1:1
        try
            if isempty(maskiererx{j,currentframe})==0
                insertion=j+1;
                break
            end
        catch
            maskiererx{1,currentframe}=[];
            maskierery{1,currentframe}=[];
            insertion=1;
        end
    end
    maskiererx{insertion,currentframe}=ximask;
    maskiererx{insertion,currentframe+1}=ximask;
    maskierery{insertion,currentframe}=yimask;
    maskierery{insertion,currentframe+1}=yimask;
    put('maskiererx' ,maskiererx);
    put('maskierery' ,maskierery);
    dispMASK
    set(handles.mask_hint, 'String', 'Mask active', 'backgroundcolor', [0.5 1 0.5]);
    toolsavailable(1);
end

% --- Executes on button press in clear_mask.
function clear_mask_Callback(hObject, eventdata, handles)
handles=gethand;
delete(findobj(gca,'tag', 'maskplot'));
put ('maskiererx',{});
put ('maskierery',{});
set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);

% --- Executes on button press in clear_current_mask.
function clear_current_mask_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
handles=gethand;
if size(filepath,1) > 1
    delete(findobj(gca,'tag', 'maskplot'));
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    maskiererx=retr('maskiererx');
    maskierery=retr('maskierery');
    for i=1:size(maskiererx,1)
        maskiererx{i,currentframe}=[];
        maskiererx{i,currentframe+1}=[];
        maskierery{i,currentframe}=[];
        maskierery{i,currentframe+1}=[];
    end
    emptycells=cellfun('isempty',maskiererx);
    if mean(double(emptycells))==1 %not very sophisticated way to determine if all cells are empty
        set(handles.mask_hint, 'String', 'Mask inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
    end
    put('maskiererx' ,maskiererx);
    put('maskierery' ,maskierery);
end

% --- Executes on button press in mask_applytoall.
function mask_applytoall_Callback(hObject, eventdata, handles)
handles=gethand;
filepath=retr('filepath');
if size(filepath,1) > 1
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    amount=size(filepath,1);
    maskiererx=retr('maskiererx');
    maskierery=retr('maskierery');
    for i=1:2:amount
        for j=1:size(maskiererx,1)
            maskiererx{j,i}=maskiererx{j,currentframe};
            maskiererx{j,i+1}=maskiererx{j,currentframe+1};
            maskierery{j,i}=maskierery{j,currentframe};
            maskierery{j,i+1}=maskierery{j,currentframe+1};
        end
    end
    put('maskiererx' ,maskiererx);
    put('maskierery' ,maskierery);
end

function preview_preprocess_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
if size(filepath,1) >1
    handles=gethand;
    toggler=retr('toggler');
    filepath=retr('filepath');
    selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
    img=imread(filepath{selected});
    clahe=get(handles.clahe_enable,'value');
    highp=get(handles.enable_highpass,'value');
    clip=get(handles.enable_clip,'value');
    intenscap=get(handles.enable_intenscap, 'value');
    submean=get(handles.enable_submean,'value');
    clahesize=str2double(get(handles.clahe_size, 'string'));
    highpsize=str2double(get(handles.highp_size, 'string'));
    clipthresh=str2double(get(handles.clip_thresh, 'string'));
    roirect=retr('roirect');
    meanimg=retr('meanimg');
    pathname=retr('pathname');
    
    
    if size (roirect,2)<4
        roirect=[1,1,size(img,2)-1,size(img,1)-1];
    end
    
    if submean == 1 %calculate the mean image in a 3D matrix
        %Subtract mean of all images selected in order to remove the
        %background of each image. It improves results of PTV
        %added by antoine 06/04/2012
        if isempty(meanimg)==1;
            meanimg=zeros(size(imread(filepath{1}),1),size(imread(filepath{1}),2));
            toolsavailable(0)
            for i=1:length(filepath)
                meanimg=(((i-1).*meanimg)+double(imread(filepath{i})))./i;
                set (handles.preview_preprocess, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*100) '%)']);
                drawnow;
            end
            set (handles.preview_preprocess, 'string', 'Preview current frame');
            toolsavailable(1)
            sliderdisp
            put ('meanimg',meanimg);
            imwrite(mat2gray(meanimg),[pathname '\MEAN.jpg'],'jpg');
            clear allimg
        end
        
    end
    
    out = PTVlab_preproc (img,roirect,clahe, clahesize,highp,highpsize,clip,clipthresh,intenscap,submean,filepath,meanimg);%'filepath' added by antoine 06/04/2012
    image(out, 'parent',gca, 'cdatamapping', 'scaled');
    colormap('gray');
    axis image;
    set(gca,'ytick',[]);
    set(gca,'xtick',[]);
    roirect=retr('roirect');
    if size(roirect,2)>1
        dispROI
    end
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    maskiererx=retr('maskiererx');
    if size(maskiererx,2)>=currentframe
        ximask=maskiererx{currentframe};
        if size(ximask,1)>1
            dispMASK
        end
    end
    
end


function preview_detection_Callback(hObject, eventdata, handles) %whole function added by antoine 09/04/2012
filepath=retr('filepath');

if size(filepath,1) >1
    handles=gethand;
    toggler=retr('toggler');
    filepath=retr('filepath');
    selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
    img=imread(filepath{selected});
    clahe=get(handles.clahe_enable,'value');
    highp=get(handles.enable_highpass,'value');
    clip=get(handles.enable_clip,'value');
    intenscap=get(handles.enable_intenscap, 'value');
    submean=get(handles.enable_submean,'value');
    clahesize=str2double(get(handles.clahe_size, 'string'));
    highpsize=str2double(get(handles.highp_size, 'string'));
    clipthresh=str2double(get(handles.clip_thresh, 'string'));
    gaussdetecmark=get(handles.gaussdetec, 'value');
    dynadetecmark=get(handles.dynadetec, 'value');
    corrthreval=str2double(get(handles.corrthre_val, 'string'));
    sigmasize=str2double(get(handles.sigma_size, 'string'));
    intthreval=str2double(get(handles.intthre_val, 'string'));
    roirect=retr('roirect');
    meanimg=retr('meanimg');
    if size (roirect,2)<4
        roirect=[1,1,size(img,2)-1,size(img,1)-1];
    end
    
    if submean == 1 %calculate the mean image in a 3D matrix
        %Subtract mean of all images selected in order to remove the
        %background of each image. It improves results of PTV
        %added by antoine 06/04/2012
        if isempty(meanimg)==1;
            meanimg=zeros(size(imread(filepath{1}),1),size(imread(filepath{1}),2));
            toolsavailable(0)
            for i=1:length(filepath)
                meanimg=(((i-1).*meanimg)+double(imread(filepath{i})))./i;
                set (handles.preview_detection, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*100) '%)']);
                drawnow;
            end
            set (handles.preview_detection, 'string', 'Preview current frame');
            toolsavailable(1)
            sliderdisp
            put ('meanimg',meanimg);
            imwrite(mat2gray(meanimg),[pathname '\MEAN.jpg'],'jpg');
            clear allimg
        end
        
    end
    
    maskiererx=retr('maskiererx');
    maskierery=retr('maskierery');
    
    
    
    try
        [out,coordi,coordj] = PTVlab_detection (img,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);
        delete(findobj(gca,'Type','text','color','r'));
    catch
        text(50,50,'The Particle Detection failed, Try to use different parameters','color','r','fontsize',8, 'BackgroundColor', 'k')
    end
    %clear value out of frame
    coordj(find(coordj+roirect(1)>roirect(1)+roirect(3)))=NaN;
    coordi(find(coordi+roirect(2)>roirect(2)+roirect(4)))=NaN;
    coordj(find(coordj+roirect(1)<roirect(1)))=NaN;
    coordi(find(coordi+roirect(2)<roirect(2)))=NaN;
    
    image(out, 'parent',gca, 'cdatamapping', 'scaled');
    hold on
    plot(coordj+roirect(1),coordi+roirect(2),'or','MarkerSize',5)
    colormap('gray');
    axis image;
    set(gca,'ytick',[]);
    set(gca,'xtick',[]);
    roirect=retr('roirect');
    
    if size(roirect,2)>1
        dispROI
    end
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    maskiererx=retr('maskiererx');
    if size(maskiererx,2)>=currentframe
        ximask=maskiererx{currentframe};
        if size(ximask,1)>1
            dispMASK
        end
    end
end

















% function dispinterrog
% handles=gethand;
% selected=2*floor(get(handles.fileselector, 'value'))-1;
% filepath=retr('filepath');
% if numel(filepath)>1
%     size_img(1)=size(imread(filepath{selected}),2)/2;
%     size_img(2)=size(imread(filepath{selected}),1)/2;
%     step=str2double(get(handles.step,'string'));
%     intarea=str2double(get(handles.intarea,'string'));
%     x=[size_img(1)  size_img(1)+intarea size_img(1)+intarea  size_img(1)            size_img(1) ];
%     y=[size_img(2)  size_img(2)            size_img(2)+intarea  size_img(2)+intarea size_img(2) ];
%     delete(findobj(gca,'Type','hggroup')); %=vectors and scatter markers
%     delete(findobj(gca,'Type','line','color','c'));
%     delete(findobj(gca,'Type','text','color','y'));
%     hold on;
%     plot(x,y,'c-', 'linewidth', 2);
%     plot(x+step,y, 'color', [0 1 1] , 'linestyle', ':');
%     hold off;
%     text(x(1),y(1)-16, ['Interrogation area example' sprintf('\n') '(dashed line = int. area nr. 2)'],'color','y','fontsize',8)
%
% end

function dispareacc
handles=gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=retr('filepath');
if numel(filepath)>1
    size_img(1)=size(imread(filepath{selected}),2)/2;
    size_img(2)=size(imread(filepath{selected}),1)/2;
    step=str2double(get(handles.step,'string'));
    area_size=str2double(get(handles.area_size,'string'));
    x=[size_img(1)  size_img(1)+area_size size_img(1)+area_size  size_img(1)            size_img(1) ];
    y=[size_img(2)  size_img(2)            size_img(2)+area_size  size_img(2)+area_size size_img(2) ];
    delete(findobj(gca,'Type','hggroup')); %=vectors and scatter markers
    delete(findobj(gca,'Type','line','color','c'));
    delete(findobj(gca,'Type','text','color','g'));
    hold on;
    plot(x,y,'c-', 'linewidth', 2);
    hold off;
    text(x(1),y(1)-30, ['Interrogation area example' sprintf('\n') '(for Cross-correlation)'],'color','g','fontsize',8)
    currentframe=2*floor(get(handles.fileselector, 'value'))-1;
    maskiererx=retr('maskiererx');
    if size(maskiererx,2)>=currentframe
        ximask=maskiererx{currentframe};
        if size(ximask,1)>1
            dispMASK
        end
    end
end

function countparticles
handles=gethand;
selected=2*floor(get(handles.fileselector, 'value'))-1;
filepath=retr('filepath');
if numel(filepath)>1
    A=imread(filepath{selected});
    clahe=get(handles.clahe_enable,'value');
    highp=get(handles.enable_highpass,'value');
    clip=get(handles.enable_clip,'value');
    intenscap=get(handles.enable_intenscap, 'value');
    submean=get(handles.enable_submean,'value');
    clahesize=str2double(get(handles.clahe_size, 'string'))*2; % faster...
    highpsize=str2double(get(handles.highp_size, 'string'));
    clipthresh=str2double(get(handles.clip_thresh, 'string'));
    roirect=retr('roirect');
    meanimg=retr('meanimg');
    A = PTVlab_preproc (A,roirect,clahe, clahesize,highp,highpsize,clip,clipthresh,intenscap,submean,filepath);%'filepath' added by antoine 06/04/2012
    A(A<=80)=0;
    A(A>80)=255;
    [spots,numA]=bwlabeln(A,8);
    XA=numA/(size(A,1)*size(A,2));
    YA=8/XA;
    Y1A=16/XA;
    recommendedMIN=round(sqrt(YA)); % 8 peaks are in Z*Z area
    recommendedMAX=round(sqrt(Y1A));
    set (handles.recommendation, 'String', ['Minimal int area size: ' int2str(recommendedMIN) 'px to ' int2str(recommendedMAX) 'px']);
end

function intarea_Callback(hObject, eventdata, handles)
overlappercent
dispinterrog

function step_Callback(hObject, eventdata, handles)
overlappercent
dispinterrog
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AnalyzeAll_Callback(hObject, eventdata, handles)
ok=checksettings;
if ok==1
    handles=gethand;
    filepath=retr('filepath');
    filename=retr('filename');
    resultslistptv=cell(0);
    resultslist=cell(0);%clear old results
    toolsavailable(0);
    set (handles.cancelbutt, 'enable', 'on');
    ismean=retr('ismean');
    maskiererx=retr('maskiererx');
    maskierery=retr('maskierery');
    MAXID=0;
    put('MAXID',MAXID);
    for i=size(ismean,1):-1:1 %remove averaged results
        if ismean(i,1)==1
            filepath(i*2,:)=[];
            filename(i*2,:)=[];
            
            filepath(i*2-1,:)=[];
            filename(i*2-1,:)=[];
            if size(maskiererx,2)>=i*2
                maskiererx(:,i*2)=[];
                maskierery(:,i*2)=[];
                maskiererx(:,i*2-1)=[];
                maskierery(:,i*2-1)=[];
            end
        end
    end
    put('filepath',filepath);
    put('filename',filename);
    put('ismean',[]);
    sliderrange
    for i=1:2:size(filepath,1)
        if i==1
           tic
        end
        cancel=retr('cancel');
        if isempty(cancel)==1 || cancel ~=1
            image1=imread(filepath{i});
            image2=imread(filepath{i+1});
            if size(image1,3)>1
                image1=uint8(mean(image1,3));
                image2=uint8(mean(image2,3));
                disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
            end
            set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow;
            clahe=get(handles.clahe_enable,'value');
            highp=get(handles.enable_highpass,'value');
            clip=get(handles.enable_clip,'value');
            intenscap=get(handles.enable_intenscap, 'value');
            submean=get(handles.enable_submean,'value');
            clahesize=str2double(get(handles.clahe_size, 'string'));
            highpsize=str2double(get(handles.highp_size, 'string'));
            clipthresh=str2double(get(handles.clip_thresh, 'string'));
            gaussdetecmark=get(handles.gaussdetec, 'value');
            dynadetecmark=get(handles.dynadetec, 'value');
            corrthreval=str2double(get(handles.corrthre_val, 'string'));
            sigmasize=str2double(get(handles.sigma_size, 'string'));
            intthreval=str2double(get(handles.intthre_val, 'string'));
            roirect=retr('roirect');
            meanimg=retr('meanimg');
            maskiererx=retr('maskiererx');
            maskierery=retr('maskierery');
            
            % Run the particle detection first
            [image1 row1 col1]= PTVlab_detection (image1,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);
            [image2 row2 col2]= PTVlab_detection (image2,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);
            
            maskiererx=retr('maskiererx');
            maskierery=retr('maskierery');
            ximask={};
            yimask={};
            if size(maskiererx,2)>=i
                for j=1:size(maskiererx,1);
                    if isempty(maskiererx{j,i})==0
                        ximask{j,1}=maskiererx{j,i};
                        yimask{j,1}=maskierery{j,i};
                    else
                        break
                    end
                end
                if size(ximask,1)>0
                    mask=[ximask yimask];
                else
                    mask=[];
                end
            else
                mask=[];
            end
            
%             %filter points in polygon
%             if isempty(mask)==0
%                 p1=[col1',row1'];
%                 p2=[col2',row2'];
%                 for ma=1:size(mask,1)
%                     node=[mask{ma,1},mask{ma,2}];
%                     in1=inpoly(p1,node);
%                     in2=inpoly(p2,node);
%                     p1(in1==1,1)=nan;
%                     p1(in1==1,2)=nan;
%                     p2(in2==1,1)=nan;
%                     p2(in2==1,2)=nan;
%                 end
%                 col1=p1(:,1)';
%                 row1=p1(:,2)';
%                 col2=p2(:,1)';
%                 row2=p2(:,2)';
%             end
            
            
            
            
            
            if size(resultslistptv,2)<(i+1)/2-1 || (i+1)/2==1 %Check if the results of the previous pair has been calculated
                indicator=1;
                prev_dis_result=[];
            else
                %             isempty(resultslistptv{1,(i+1)/2-1})
                if isempty(resultslistptv{1,(i+1)/2-1})==1
                    indicator=1;
                    prev_dis_result=[];
                elseif isempty(resultslistptv{1,(i+1)/2-1})==0
                    indicator=0;
                    prev_dis_result=[];
                    prev_dis_result(:,1)=resultslistptv{1,((i+1)/2-1)};
                    prev_dis_result(:,2)=resultslistptv{2,((i+1)/2-1)};
                    prev_dis_result(:,3)=resultslistptv{3,((i+1)/2-1)};
                    prev_dis_result(:,4)=resultslistptv{4,((i+1)/2-1)};
                    prev_dis_result(:,5)=resultslistptv{5,((i+1)/2-1)};
                    prev_dis_result(:,6)=resultslistptv{6,((i+1)/2-1)};
                end
            end
            %             interrogationarea=str2double(get(handles.intarea, 'string'));
            %             step=str2double(get(handles.step, 'string'));
            %             subpixfinder=get(handles.subpix,'value');
            %             if get(handles.dcc,'Value')==1
            %                 [x y u v typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask, roirect);
            %             elseif get(handles.fftmulti,'Value')==1
            %                 passes=1;
            %                 if get(handles.checkbox26,'value')==1
            %                     passes=2;
            %                 end
            %                 if get(handles.checkbox27,'value')==1
            %                     passes=3;
            %                 end
            %                 if get(handles.checkbox28,'value')==1
            %                     passes=4;
            %                 end
            %                 int2=str2num(get(handles.edit50,'string'));
            %                 int3=str2num(get(handles.edit51,'string'));
            %                 int4=str2num(get(handles.edit52,'string'));
            %                 contents = get(handles.popupmenu16,'string');
            %                 imdeform=contents{get(handles.popupmenu16,'Value')};
            %                 [x y u v typevector] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask, roirect,passes,int2,int3,int4,imdeform);
            %             end
            
            ccmark=get(handles.cc, 'value');
            rmmark=get(handles.rm, 'value');
            hymark=get(handles.hy, 'value');
            det_nummark=get(handles.det_num,'value');
            det_areamark=get(handles.det_area,'value');
            num_part=str2double(get(handles.num_part,'string'));
            area_size=str2double(get(handles.area_size,'string'));
            corrcc=str2double(get(handles.corrcc,'string'));
            percentcc=str2double(get(handles.percentcc,'string'));
            tn=str2double(get(handles.tn,'string'));
            tq=str2double(get(handles.tq,'string'));
            minneifrm=get(handles.minneifrm,'string');
            tqfrm1=str2double(get(handles.tqfrm1,'string'));
            minprob=str2double(get(handles.minprob,'string'));
            tqfcc=80;
            epsilon=0.01;
            percentrm=70;
            ninit=1;
            nframe=(i+1)/2;
            
            %run the ptv algorithm and save the results in resultslistptv
            [dis_result,indicator]=ptv_CCRM(image1,image2,num_part,tn,tq,tqfcc,tqfrm1,percentcc,percentrm,epsilon,...
                corrcc,minprob,ccmark,rmmark,hymark,minneifrm,indicator,det_nummark,det_areamark,area_size,roirect,...
                row1,col1,row2,col2,prev_dis_result,ninit,nframe,roirect);
            
            if isempty(roirect)==1
                resultslistptv{1,(i+1)/2}=dis_result(:,1);
                resultslistptv{2,(i+1)/2}=dis_result(:,2);
                resultslistptv{3,(i+1)/2}=dis_result(:,3);
                resultslistptv{4,(i+1)/2}=dis_result(:,4);
                resultslistptv{5,(i+1)/2}=dis_result(:,5);
                resultslistptv{6,(i+1)/2}=dis_result(:,6);
            else
                resultslistptv{1,(i+1)/2}=dis_result(:,1)+roirect(2);
                resultslistptv{2,(i+1)/2}=dis_result(:,2)+roirect(1);
                resultslistptv{3,(i+1)/2}=dis_result(:,3)+roirect(2);
                resultslistptv{4,(i+1)/2}=dis_result(:,4)+roirect(1);
                resultslistptv{5,(i+1)/2}=dis_result(:,5);
                resultslistptv{6,(i+1)/2}=dis_result(:,6);
                %         resultslistptv{6,(i+1)/2}=[];
            end
            
            
            if ~isempty(dis_result)
                if isempty(roirect)==1
                    resultslistptv{1,(i+1)/2}=dis_result(:,1);
                    resultslistptv{2,(i+1)/2}=dis_result(:,2);
                    resultslistptv{3,(i+1)/2}=dis_result(:,3);
                    resultslistptv{4,(i+1)/2}=dis_result(:,4);
                    resultslistptv{5,(i+1)/2}=dis_result(:,5);
                    resultslistptv{6,(i+1)/2}=dis_result(:,6);
                else
                    resultslistptv{1,(i+1)/2}=dis_result(:,1)+roirect(2);
                    resultslistptv{2,(i+1)/2}=dis_result(:,2)+roirect(1);
                    resultslistptv{3,(i+1)/2}=dis_result(:,3)+roirect(2);
                    resultslistptv{4,(i+1)/2}=dis_result(:,4)+roirect(1);
                    resultslistptv{5,(i+1)/2}=dis_result(:,5);
                    resultslistptv{6,(i+1)/2}=dis_result(:,6);
                    %         resultslistptv{6,(i+1)/2}=[];
                end
                
                
                %calculate the interpolated field and save the results in resultslist
                
                try
                    x=resultslistptv{2,(i+1)/2};
                    y=resultslistptv{1,(i+1)/2};
                    typevector=resultslistptv{5,(i+1)/2};
                    u=resultslistptv{4,(i+1)/2}-resultslistptv{2,(i+1)/2};
                    v=resultslistptv{3,(i+1)/2}-resultslistptv{1,(i+1)/2};
                    typevector=resultslistptv{5,(i+1)/2};
                    
                    %make cluster of points. idx is the index of each cluster
                    RadiusCluster=80; %in pixel
                    idx=ncluster(x(typevector==1),y(typevector==1),RadiusCluster);
                    
                    %Give the matrix X, Y, U  V (can be improved)
                    meshsize=10; %(in pixel)
                    currentimage=imread(filepath{i});
                    [X Y U V InMask] = ptv2grid(x,y,u,v,currentimage,roirect,meshsize,idx,maskiererx,maskierery);
                    
                    %save it in resultlist
                    resultslist{1,(i+1)/2}=X;
                    resultslist{2,(i+1)/2}=Y;
                    resultslist{3,(i+1)/2}=U;
                    resultslist{4,(i+1)/2}=V;
                catch
                    resultslist{1,(i+1)/2}=[];
                    resultslist{2,(i+1)/2}=[];
                    resultslist{3,(i+1)/2}=[];
                    resultslist{4,(i+1)/2}=[];
                end
                
                
            else
                resultslistptv{1,(i+1)/2}=nan;
                resultslistptv{2,(i+1)/2}=nan;
                resultslistptv{3,(i+1)/2}=nan;
                resultslistptv{4,(i+1)/2}=nan;
                resultslistptv{5,(i+1)/2}=nan;
                
                resultslist{1,(i+1)/2}=nan;
                resultslist{2,(i+1)/2}=nan;
                resultslist{3,(i+1)/2}=nan;
                resultslist{4,(i+1)/2}=nan;
                resultslist{5,(i+1)/2}=nan;
                
            end
            
            
            put('resultslist',resultslist);
            put('resultslistptv',resultslistptv);
            set(handles.fileselector, 'value', (i+1)/2);
            set(handles.progress, 'string' , ['Frame progress: 100%'])
            set(handles.overall, 'string' , ['Total progress: ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%'])
            put('subtr_u', 0);
            put('subtr_v', 0);
            sliderdisp
            xpos=size(image1,2)/2-40;
            text(xpos,50, ['Analyzing... ' int2str((i+1)/2/(size(filepath,1)/2)*100) '%' ],'color', 'r','FontName','FixedWidth','fontweight', 'bold', 'fontsize', 20, 'tag', 'annoyingthing')
            zeit=toc;
            done=(i+1)/2;
            tocome=(size(filepath,1)/2)-done;
            zeit=zeit/done*tocome;
            hrs=zeit/60^2;
            mins=(hrs-floor(hrs))*60;
            secs=(mins-floor(mins))*60;
            hrs=floor(hrs);
            mins=floor(mins);
            secs=floor(secs);
            set(handles.totaltime,'string', ['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
        end %cancel==0
    end
    delete(findobj('tag', 'annoyingthing'));
    set(handles.overall, 'string' , ['Total progress: ' int2str(100) '%'])
    set(handles.totaltime, 'String','Time left: N/A');
    put('cancel',0);
    try
        if exist(fullfile(pwd,'PTVlab_temp.mat'),'file') ==2
            delete(fullfile(pwd,'PTVlab_temp.mat'))
        end
        savesessionsfuntion (pwd,'PTVlab_temp.mat')
        set(handles.messagetext, 'String',['-> temporary results saved as' sprintf('\n') '   ''PTVlab_temp.mat''.']);
    catch
        set(handles.messagetext, 'String','-> could not save temporary results.');
    end
end
toolsavailable(1);



function AnalyzeSingle_Callback(hObject, eventdata, handles)
handles=gethand;
ok=checksettings;
if ok==1
    resultslist=retr('resultslist');
    resultslistptv=retr('resultslistptv');
    set(handles.progress, 'string' , ['Frame progress: 0%']);drawnow;
    handles=gethand;
    filepath=retr('filepath');
    selected=2*floor(get(handles.fileselector, 'value'))-1;
    ismean=retr('ismean');
    if size(ismean,1)>=(selected+1)/2
        if ismean((selected+1)/2,1) ==1
            currentwasmean=1;
        else
            currentwasmean=0;
        end
    else
        currentwasmean=0;
    end
    if currentwasmean==0
        image1=imread(filepath{selected});
        image2=imread(filepath{selected+1});
        if size(image1,3)>1
            image1=uint8(mean(image1,3));
            image2=uint8(mean(image2,3));
            disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
        end
        clahe=get(handles.clahe_enable,'value');
        highp=get(handles.enable_highpass,'value');
        clip=get(handles.enable_clip,'value');
        intenscap=get(handles.enable_intenscap, 'value');
        submean=get(handles.enable_submean,'value');
        clahesize=str2double(get(handles.clahe_size, 'string'));
        highpsize=str2double(get(handles.highp_size, 'string'));
        clipthresh=str2double(get(handles.clip_thresh, 'string'));
        gaussdetecmark=get(handles.gaussdetec, 'value');
        dynadetecmark=get(handles.dynadetec, 'value');
        corrthreval=str2double(get(handles.corrthre_val, 'string'));
        sigmasize=str2double(get(handles.sigma_size, 'string'));
        intthreval=str2double(get(handles.intthre_val, 'string'));
        roirect=retr('roirect');
        meanimg=retr('meanimg');
        maskiererx=retr('maskiererx');
        maskierery=retr('maskierery');
        % Run the particle detection first
        [image1 row1 col1]= PTVlab_detection (image1,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);
        [image2 row2 col2]= PTVlab_detection (image2,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);
        
        
        maskiererx=retr('maskiererx');
        maskierery=retr('maskierery');
        ximask={};
        yimask={};
        if size(maskiererx,2)>=selected
            for i=1:size(maskiererx,1);
                if isempty(maskiererx{i,selected})==0
                    ximask{i,1}=maskiererx{i,selected};
                    yimask{i,1}=maskierery{i,selected};
                else
                    break
                end
            end
            if size(ximask,1)>0
                mask=[ximask yimask];
            else
                mask=[];
            end
        else
            mask=[];
        end
        
        %         %filter points in polygon
        %         if isempty(mask)==0
        %             p1=[col1',row1'];
        %             p2=[col2',row2'];
        %             for i=1:size(mask,1)
        %                 node=[mask{i,1},mask{i,2}];
        %                 in1=inpoly(p1,node);
        %                 in2=inpoly(p2,node);
        %                 p1(in1==1,1)=nan;
        %                 p1(in1==1,2)=nan;
        %                 p2(in2==1,1)=nan;
        %                 p2(in2==1,2)=nan;
        %             end
        %             col1=p1(:,1)';
        %             row1=p1(:,2)';
        %             col2=p2(:,1)';
        %             row2=p2(:,2)';
        %         end
        
        
        if size(resultslistptv,2)<(selected+1)/2-1 || (selected+1)/2==1 %Check if the results of the previous pair has been calculated
            indicator=1;
            prev_dis_result=[];
        else
            isempty(resultslistptv{1,(selected+1)/2-1})
            if isempty(resultslistptv{1,(selected+1)/2-1})==1
                indicator=1;
                prev_dis_result=[];
            elseif isempty(resultslistptv{1,(selected+1)/2-1})==0
                indicator=0;
                prev_dis_result(:,1)=resultslistptv{1,((selected+1)/2-1)};
                prev_dis_result(:,2)=resultslistptv{2,((selected+1)/2-1)};
                prev_dis_result(:,3)=resultslistptv{3,((selected+1)/2-1)};
                prev_dis_result(:,4)=resultslistptv{4,((selected+1)/2-1)};
                prev_dis_result(:,5)=resultslistptv{5,((selected+1)/2-1)};
                prev_dis_result(:,6)=resultslistptv{6,((selected+1)/2-1)};
            end
        end
        
        
        %         interrogationarea=str2double(get(handles.intarea, 'string'));
        %         step=str2double(get(handles.step, 'string'));
        %         subpixfinder=get(handles.subpix,'value');
        %         if get(handles.dcc,'Value')==1
        %             [x y u v typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask, roirect);
        %         elseif get(handles.fftmulti,'Value')==1
        %             passes=1;
        %             if get(handles.checkbox26,'value')==1
        %                 passes=2;
        %             end
        %             if get(handles.checkbox27,'value')==1
        %                 passes=3;
        %             end
        %             if get(handles.checkbox28,'value')==1
        %                 passes=4;
        %             end
        %             int2=str2num(get(handles.edit50,'string'));
        %             int3=str2num(get(handles.edit51,'string'));
        %             int4=str2num(get(handles.edit52,'string'));
        %             contents = get(handles.popupmenu16,'string');
        %             imdeform=contents{get(handles.popupmenu16,'Value')}
        %             [x y u v typevector] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask, roirect,passes,int2,int3,int4,imdeform);
        %         end
        
        ccmark=get(handles.cc, 'value');
        rmmark=get(handles.rm, 'value');
        hymark=get(handles.hy, 'value');
        det_nummark=get(handles.det_num,'value');
        det_areamark=get(handles.det_area,'value');
        num_part=str2double(get(handles.num_part,'string'));
        area_size=str2double(get(handles.area_size,'string'));
        corrcc=str2double(get(handles.corrcc,'string'));
        percentcc=str2double(get(handles.percentcc,'string'));
        tn=str2double(get(handles.tn,'string'));
        tq=str2double(get(handles.tq,'string'));
        minneifrm=get(handles.minneifrm,'string');
        tqfrm1=str2double(get(handles.tqfrm1,'string'));
        minprob=str2double(get(handles.minprob,'string'));
        tqfcc=80;
        epsilon=0.01;
        percentrm=70;
        
        %run the ptv algorithm and save the results in resultslistptv
        nframe=(selected+1)/2;
        ninit=nframe;
        [dis_result,indicator]=ptv_CCRM(image1,image2,num_part,tn,tq,tqfcc,tqfrm1,percentcc,percentrm,epsilon,...
            corrcc,minprob,ccmark,rmmark,hymark,minneifrm,indicator,det_nummark,det_areamark,area_size,roirect,...
            row1,col1,row2,col2,prev_dis_result,ninit,nframe,roirect);
        
        if ~isempty(dis_result)
            if isempty(roirect)==1
                resultslistptv{1,(selected+1)/2}=dis_result(:,1);
                resultslistptv{2,(selected+1)/2}=dis_result(:,2);
                resultslistptv{3,(selected+1)/2}=dis_result(:,3);
                resultslistptv{4,(selected+1)/2}=dis_result(:,4);
                resultslistptv{5,(selected+1)/2}=dis_result(:,5);
                resultslistptv{6,(selected+1)/2}=dis_result(:,6);
            else
                resultslistptv{1,(selected+1)/2}=dis_result(:,1)+roirect(2);
                resultslistptv{2,(selected+1)/2}=dis_result(:,2)+roirect(1);
                resultslistptv{3,(selected+1)/2}=dis_result(:,3)+roirect(2);
                resultslistptv{4,(selected+1)/2}=dis_result(:,4)+roirect(1);
                resultslistptv{5,(selected+1)/2}=dis_result(:,5);
                resultslistptv{6,(selected+1)/2}=dis_result(:,6);
                %         resultslistptv{6,(selected+1)/2}=[];
            end
            
            
            %calculate the interpolated field and save the results in resultslist
            
            try
                x=resultslistptv{2,(selected+1)/2};
                y=resultslistptv{1,(selected+1)/2};
                typevector=resultslistptv{5,(selected+1)/2};
                u=resultslistptv{4,(selected+1)/2}-resultslistptv{2,(selected+1)/2};
                v=resultslistptv{3,(selected+1)/2}-resultslistptv{1,(selected+1)/2};
                typevector=resultslistptv{5,(selected+1)/2};
                
                %make cluster of points. idx is the index of each cluster
                RadiusCluster=80; %in pixel
                idx=ncluster(x(typevector==1),y(typevector==1),RadiusCluster);
                
                %Give the matrix X, Y, U  V (can be improved)
                meshsize=10; %(in pixel)
                currentimage=imread(filepath{selected});
                [X Y U V InMask] = ptv2grid(x,y,u,v,currentimage,roirect,meshsize,idx,maskiererx,maskierery);
                
                
                %save it in resultlist
                resultslist{1,(selected+1)/2}=X;
                resultslist{2,(selected+1)/2}=Y;
                resultslist{3,(selected+1)/2}=U;
                resultslist{4,(selected+1)/2}=V;
            catch
                resultslist{1,(selected+1)/2}=[];
                resultslist{2,(selected+1)/2}=[];
                resultslist{3,(selected+1)/2}=[];
                resultslist{4,(selected+1)/2}=[];
            end
            
            
            
            
        else
            resultslistptv{1,(selected+1)/2}=nan;
            resultslistptv{2,(selected+1)/2}=nan;
            resultslistptv{3,(selected+1)/2}=nan;
            resultslistptv{4,(selected+1)/2}=nan;
            resultslistptv{5,(selected+1)/2}=nan;
            
            resultslist{1,(selected+1)/2}=nan;
            resultslist{2,(selected+1)/2}=nan;
            resultslist{3,(selected+1)/2}=nan;
            resultslist{4,(selected+1)/2}=nan;
            resultslist{5,(selected+1)/2}=nan;
            
        end
        
        put('derived', [])
        put('derivedRW',[]);
        put('resultslist',resultslist);
        put('resultslistptv',resultslistptv);
        
        set(handles.progress, 'string' , ['Frame progress: 100%'])
        set(handles.overall, 'string' , ['Total progress: 100%'])
        set(handles.totaltime, 'String','Time left: N/A');
        set(handles.messagetext, 'String','');
        put('subtr_u', 0);
        put('subtr_v', 0);
        sliderdisp
    end
    
end

function ok=checksettings
handles=gethand;
mess={};
filepath=retr('filepath');
if size(filepath,1) <2
    mess{size(mess,2)+1}='No images were loaded';
end
if get(handles.clahe_enable, 'value')==1
    if isnan(str2double(get(handles.clahe_size, 'string')))==1
        mess{size(mess,2)+1}='CLAHE window size contains NaN';
    end
end
if get(handles.enable_highpass, 'value')==1
    if isnan(str2double(get(handles.highp_size, 'string')))==1
        mess{size(mess,2)+1}='Highpass filter size contains NaN';
    end
end
if isnan(str2double(get(handles.corrthre_val, 'string')))==1
    mess{size(mess,2)+1}='Correlation threshold contains NaN';
end
if isnan(str2double(get(handles.sigma_size, 'string')))==1
    mess{size(mess,2)+1}='sigma contains NaN';
end
if isnan(str2double(get(handles.intthre_val, 'string')))==1
    mess{size(mess,2)+1}='Intensity threshold contains NaN';
end

if get(handles.enable_clip, 'value')==1
    if isnan(str2double(get(handles.clip_thresh, 'string')))==1
        mess{size(mess,2)+1}='Clipping threshold contains NaN';
    end
end
if isnan(str2double(get(handles.intarea, 'string')))==1
    mess{size(mess,2)+1}='Interrogation area size contains NaN';
end
if isnan(str2double(get(handles.step, 'string')))==1
    mess{size(mess,2)+1}='Step size contains NaN';
end
if isnan(str2double(get(handles.step, 'string')))==1
    mess{size(mess,2)+1}='Step size contains NaN';
end




if get(handles.cc, 'value')==1 | get(handles.hy, 'value')==1
    if get(handles.det_num, 'value')==1
        if isnan(str2double(get(handles.num_part, 'string')))==1
            mess{size(mess,2)+1}='Nr. of particles contains NaN';
        end
    elseif get(handles.det_area, 'value')==1
        if isnan(str2double(get(handles.area_size, 'string')))==1
            mess{size(mess,2)+1}='Interrogation area contains NaN';
        end
    end
    if isnan(str2double(get(handles.corrcc, 'string')))==1
        mess{size(mess,2)+1}='Minimum correlation contains NaN';
    end
    if isnan(str2double(get(handles.percentcc, 'string')))==1
        mess{size(mess,2)+1}='Similaity neighbors contains NaN';
    end
end



if get(handles.rm, 'value')==1 | get(handles.hy, 'value')==1
    if isnan(str2double(get(handles.tn, 'string')))==1
        mess{size(mess,2)+1}='Rd. of neighbors contains NaN';
    end
    if isnan(str2double(get(handles.tq, 'string')))==1
        mess{size(mess,2)+1}='Relaxation Rd. contains NaN';
    end
    if isnan(str2double(get(handles.minneifrm, 'string')))==1
        mess{size(mess,2)+1}='Min. # of neighbors contains NaN';
    end
    if isnan(str2double(get(handles.tqfrm1, 'string')))==1
        mess{size(mess,2)+1}='Filtering of local vel. contains NaN';
    end
    if isnan(str2double(get(handles.minprob, 'string')))==1
        mess{size(mess,2)+1}='Min. Max. probability. contains NaN';
    end
end


if size(mess,2)>0 %error somewhere
    msgbox(['Errors found:' mess],'Errors detected.','warn','modal')
    ok=0;
else
    ok=1;
end

function cancelbutt_Callback(hObject, eventdata, handles)
put('cancel',1);
drawnow;
toolsavailable(1);

function load_settings_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile('*.mat','Load PTVlab settings','PTVlab_settings.mat');
if isequal(FileName,0)==0
    read_settings (FileName,PathName)
end

function read_settings (FileName,PathName)
handles=gethand;
load(fullfile(PathName,FileName));
% set(handles.clahe_enable,'value',clahe_enable);
clahe_enable=0;
set(handles.clahe_enable,'value',clahe_enable);
set(handles.clahe_size,'string',clahe_size);
set(handles.enable_highpass,'value',enable_highpass);
set(handles.highp_size,'string',highp_size);
set(handles.enable_clip,'value',enable_clip);
set(handles.clip_thresh,'string',clip_thresh);
set(handles.enable_intenscap,'value',enable_intenscap);
set(handles.enable_submean,'value',enable_submean);
if vars.gaussdetecmark==1
    set(handles.corrthre_val,'value',retr('corrthre_val'));
    set(handles.sigma_size,'value',retr('sigma_size'));
    set(handles.intthre_val,'value',retr('intthre_val'));
end
if vars.dynadetecmark==1
    %         set(handles.corrthre_val,'value',retr('corrthre_val'));
    %         set(handles.sigma_size,'value',retr('sigma_size'));
    %         set(handles.intthre_val,'value',retr('intthre_val'));
end
set(handles.intarea,'string',intarea);
set(handles.step,'string',stepsize);
set(handles.subpix,'value',subpix);  %popup
set(handles.stdev_check,'value',stdev_check);
set(handles.cc,'value',ccmark);
set(handles.rm,'value',rmmark);
set(handles.hy,'value',hymark);
set(handles.det_num,'value',det_nummark);
set(handles.det_area,'value',det_areamark);
set(handles.num_part,'string',num_part);
set(handles.area_size,'string',area_size);
set(handles.corrcc,'string',corrcc);
set(handles.percentcc,'string',percentcc);
set(handles.tn,'string',tn);
set(handles.tq,'string',tq);
set(handles.minneifrm,'string',minneifrm);
set(handles.tqfrm1,'string',tqfrm1);
set(handles.minprob,'string',minprob);
set(handles.stdev_thresh,'string',stdev_thresh);
set(handles.loc_median,'value',loc_median);
set(handles.loc_med_thresh,'string',loc_med_thresh);
set(handles.epsilon,'string',epsilon);
% set(handles.interpol_missing,'value',interpol_missing);
set(handles.vectorscale,'string',vectorscale);
set(handles.colormap_choice,'value',colormap_choice); %popup
set(handles.addfileinfo,'value',addfileinfo);
set(handles.add_header,'value',add_header);
set(handles.delimiter,'value',delimiter);%popup
set(handles.img_not_mask,'value',img_not_mask);
set(handles.autoscale_vec,'value',autoscale_vec);

set(handles.popupmenu16, 'value',imginterpol);
set(handles.dcc, 'value',dccmark);
set(handles.fftmulti, 'value',fftmark);
if fftmark==1
    set (handles.uipanel36,'visible','on')
else
    set (handles.uipanel36,'visible','off')
end

set(handles.checkbox26, 'value',pass2);
set(handles.checkbox27, 'value',pass3);
set(handles.checkbox28, 'value',pass4);
set(handles.edit50, 'string',pass2val);
set(handles.edit51, 'string',pass3val);
set(handles.edit52, 'string',pass4val);
set(handles.text126, 'string',step2);
set(handles.text127, 'string',step3);
set(handles.text128, 'string',step4);
set(handles.holdstream, 'value',holdstream);
set(handles.streamlamount, 'string',streamlamount);
set(handles.streamlcolor, 'value',streamlcolor);
set(handles.streamlwidth, 'value',streamlcolor);

set(handles.realdist, 'string',realdist);
set(handles.time_inp, 'string',time_inp);

if caluv~=1 || calxy ~=1
    set(handles.calidisp, 'string', ['1 px/imagepair = ' num2str(round(caluv*1000)/1000) ' m/s'],  'backgroundcolor', [0.5 1 0.5]);
end

put('calxy',calxy);
put('caluv',caluv);

% function curr_settings_Callback(hObject, eventdata, handles)
% handles=gethand;
% clahe_enable=get(handles.clahe_enable,'value');
% clahe_size=get(handles.clahe_size,'string');
% enable_highpass=get(handles.enable_highpass,'value');
% highp_size=get(handles.highp_size,'string');
% enable_clip=get(handles.enable_clip,'value');
% clip_thresh=get(handles.clip_thresh,'string');
% enable_intenscap=get(handles.enable_intenscap,'value');
% enable_submean=get(handles.enable_submean,'value');
% corrthre_val=get(handles.corrthre_val,'string');
% sigma_size=get(handles.sigma_size,'string');
% intthre_val=get(handles.intthre_val,'string');
% gaussdetecmark=get(handles.gaussdetec, 'value');
% intarea=get(handles.intarea,'string');
% stepsize=get(handles.step,'string');
% subpix=get(handles.subpix,'value');  %popup
% ccmark=get(handles.cc, 'value');
% rmmark=get(handles.rm, 'value');
% hymark=get(handles.hy, 'value');
% det_nummark=get(handles.det_num,'value');
% det_areamark=get(handles.det_area,'value');
% num_part=get(handles.num_part,'string');
% area_size=get(handles.area_size,'string');
% corrcc=get(handles.corrcc,'string');
% percentcc=get(handles.percentcc,'string');
% tn=get(handles.tn,'string');
% tq=get(handles.tq,'string');
% minneifrm=get(handles.minneifrm,'string');
% tqfrm1=get(handles.tqfrm1,'string');
% minprob=get(handles.minprob,'string');
% stdev_check=get(handles.stdev_check,'value');
% stdev_thresh=get(handles.stdev_thresh,'string');
% loc_median=get(handles.loc_median,'value');
% loc_med_thresh=get(handles.loc_med_thresh,'string');
% epsilon=get(handles.epsilon,'string');
% % interpol_missing=get(handles.interpol_missing,'value');
% vectorscale=get(handles.vectorscale,'string');
% colormap_choice=get(handles.colormap_choice,'value'); %popup
% addfileinfo=get(handles.addfileinfo,'value');
% add_header=get(handles.add_header,'value');
% delimiter=get(handles.delimiter,'value');%popup
% img_not_mask=get(handles.img_not_mask,'value');
% autoscale_vec=get(handles.autoscale_vec,'value');
%
% imginterpol=get(handles.popupmenu16, 'value');
% dccmark=get(handles.dcc, 'value');
% fftmark=get(handles.fftmulti, 'value');
%
% pass2=get(handles.checkbox26, 'value');
% pass3=get(handles.checkbox27, 'value');
% pass4=get(handles.checkbox28, 'value');
% pass2val=get(handles.edit50, 'string');
% pass3val=get(handles.edit51, 'string');
% pass4val=get(handles.edit52, 'string');
% step2=get(handles.text126, 'string');
% step3=get(handles.text127, 'string');
% step4=get(handles.text128, 'string');
% holdstream=get(handles.holdstream, 'value');
% streamlamount=get(handles.streamlamount, 'string');
% streamlcolor=get(handles.streamlcolor, 'value');
% streamlcolor=get(handles.streamlwidth, 'value');
% realdist=get(handles.realdist, 'string');
% time_inp=get(handles.time_inp, 'string');
%
% calxy=retr('calxy');
% caluv=retr('caluv');
%
%
% if ispc==1
%     [FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PTVlab_set_' getenv('USERNAME') '.mat']);
% else
%     try
%         [FileName,PathName] = uiputfile('*.mat','Save current settings as...',['PTVlab_set_' getenv('USER') '.mat']);
%     catch
%         [FileName,PathName] = uiputfile('*.mat','Save current settings as...','PTVlab_set.mat');
%     end
% end
% clear handles hObject eventdata
% if isequal(FileName,0)==0
%     save('-v6', fullfile(PathName,FileName))
% end

function vel_limit_Callback(hObject, eventdata, handles)
% toolsavailable(0)
%if analys existing
resultslist=retr('resultslist');
resultslistptv=retr('resultslistptv');
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
    x=resultslistptv{2,(currentframe+1)/2};
    y=resultslistptv{1,(currentframe+1)/2};
    %     u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
    %     v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
    %     if size(x,2)>1
    %         if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
    %             index=1;
    %             for i = 1:size(resultslistptv,2)
    %                 x=resultslistptv{2,i};
    %                 if i==1
    %                     sizex=size(x,1);
    %                 end
    %                 if size(x,1)>1 && size(x,1)==sizex
    %                     u(:,index)=resultslistptv{4,i}-resultslistptv{2,i};
    %                     v(:,index)=resultslistptv{3,i}-resultslistptv{1,i};
    %                     index=index+1;
    %                 end
    %             end
    %         else
    %             y=resultslistptv{1,(currentframe+1)/2};
    %             u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
    %             v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
    %             typevector=resultslist{5,(currentframe+1)/2};
    %         end
    
    if size(x,1)>1
        if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
            for i=1:size(resultslistptv,2)
                if isempty(resultslistptv{1,i})==1
                    alllength(i)=0;
                else
                    alllength(i)=length(resultslistptv{1,i});
                end
            end
            maxlength=nanmax(alllength);
            for i=1:size(resultslistptv,2)
                u(:,i)=[resultslistptv{4,i}-resultslistptv{2,i}; nan*ones(maxlength-alllength(i),1)];
                v(:,i)=[resultslistptv{3,i}-resultslistptv{1,i}; nan*ones(maxlength-alllength(i),1)];%
            end
            
        else
            y=resultslistptv{1,(currentframe+1)/2};
            u=resultslistptv{4,(currentframe+1)/2}-resultslistptv{2,(currentframe+1)/2};
            v=resultslistptv{3,(currentframe+1)/2}-resultslistptv{1,(currentframe+1)/2};
            typevector=resultslistptv{5,(currentframe+1)/2};
        end
        
        
        
        
        velrect=retr('velrect');
        caluv=retr('caluv');
        
        
        
        
        if numel(velrect>0)
            %user already selected window before...
            %"filter u+v" and display scatterplot
            %problem: if user selects limits and then wants to refine vel
            %limits, all data is filterd out...
            umin=velrect(1);
            umax=velrect(3)+umin;
            vmin=velrect(2);
            vmax=velrect(4)+vmin;
            %             %check if all results are nan...
            %
            u_backup=u;
            v_backup=v;
            u(u*caluv<umin)=NaN;
            u(u*caluv>umax)=NaN;
            v(u*caluv<umin)=NaN;
            v(u*caluv>umax)=NaN;
            v(v*caluv<vmin)=NaN;
            v(v*caluv>vmax)=NaN;
            u(v*caluv<vmin)=NaN;
            u(v*caluv>vmax)=NaN;
            if mean(mean(mean((isnan(u)))))>0.9 || mean(mean(mean((isnan(v)))))>0.9
                disp('User calibrated after selecting velocity limits. Discarding limits.')
                u=u_backup;
                v=v_backup;
            end
            
        end
        datau=reshape(u*caluv,1,size(u,1)*size(u,2));
        datav=reshape(v*caluv,1,size(v,1)*size(v,2));
        
        %         skipper=ceil(size(datau,2)/8000);
        %try lasso.m
        scatter(datau,datav, 'b.');
        oldsize=get(gca,'outerposition');
        newsize=[0 0 oldsize(3)*0.87 oldsize(4)*0.87];
        set(gca,'outerposition', newsize)
        %%{
        xlabel(gca, 'u velocity', 'fontsize', 12)
        ylabel(gca, 'v velocity', 'fontsize', 12)
        grid on
        %axis equal;
        set (gca, 'tickdir', 'in');
        rangeu=nanmax(nanmax(u*caluv))-nanmin(nanmin(u*caluv));
        rangev=nanmax(nanmax(v*caluv))-nanmin(nanmin(v*caluv));
        set(gca,'xlim',[nanmin(nanmin(u*caluv))-rangeu*0.15 nanmax(nanmax(u*caluv))+rangeu*0.15])
        set(gca,'ylim',[nanmin(nanmin(v*caluv))-rangev*0.15 nanmax(nanmax(v*caluv))+rangev*0.15])
        %=range of data +- 15%
        %%}
        velrect = getrect(gca);
        if velrect(1,3)~=0 && velrect(1,4)~=0
            put('velrect', velrect);
            set (handles.vel_limit_active, 'String', 'Limit active', 'backgroundcolor', [0.5 1 0.5]);
            umin=velrect(1);
            umax=velrect(3)+umin;
            vmin=velrect(2);
            vmax=velrect(4)+vmin;
            set (handles.limittext, 'String', ['valid u: ' num2str(round(umin*100)/100) ' to ' num2str(round(umax*100)/100) sprintf('\n') 'valid v: ' num2str(round(vmin*100)/100) ' to ' num2str(round(vmax*100)/100) ]);
            sliderdisp
            delete(findobj(gca,'Type','text','color','r'));
            text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',8, 'BackgroundColor', 'k')
            set (handles.vel_limit, 'String', 'Refine velocity limits');
        else
            sliderdisp
            text(50,50,'Invalid selection: Click and hold left mouse button to create a rectangle.','color','r','fontsize',8, 'BackgroundColor', 'k')
        end
    end
end

toolsavailable(1)
figure1_ResizeFcn(gcf)

function apply_filter_current_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
put('derived', []); %clear derived parameters if user modifies source data
put('derivedRW',[]);
filtervectors(currentframe)
TrackID=[];
put('TrackID',TrackID);
%put('manualdeletion',[]); %only valid one time, why...? Could work without this line.
sliderdisp;

function apply_filter_all_Callback(hObject, eventdata, handles)
handles=gethand;
filepath=retr('filepath');
toolsavailable(0)
%put('manualdeletion',[]); %not available for filtering several images
put('derived', []);
put('derivedRW',[]);%clear derived parameters if user modifies source data
for i=1:floor(size(filepath,1)/2)+1
    filtervectors(i)
    set (handles.apply_filter_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
    drawnow;
end
set (handles.apply_filter_all, 'string', 'Apply to all frames');
TrackID=[];
put('TrackID',TrackID);
toolsavailable(1)
sliderdisp;

function restore_all_Callback(hObject, eventdata, handles)
%clears resultslist at 7,8,9
resultslistptv=retr('resultslistptv');


if size(resultslistptv,1) > 6
    resultslistptv(7:9,:)={[]};
    if size(resultslistptv,1) > 9
        resultslistptv(10:11,:)={[]};
    end
    put('resultslistptv', resultslistptv);
    sliderdisp
end
put('manualdeletion',[]);

% --- Executes on button press in clear_vel_limit.
function clear_vel_limit_Callback(hObject, eventdata, handles)
put('velrect', []);
handles=gethand;
set (handles.vel_limit_active, 'String', 'Limit inactive', 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
set (handles.limittext, 'String', '');
set (handles.vel_limit, 'String', 'Select velocity limits');

function filtervectors(frame)
%executes filters one after another, writes results to resultslist 7,8,9
handles=gethand;
resultslist=retr('resultslist');
resultslistptv=retr('resultslistptv');
roirect=retr('roirect');
filepath=retr('filepath');
try
    if isempty(resultslistptv{1,frame})==0
        resultslist{10,frame}=[]; %remove smoothed results when user modifies original data
        resultslist{11,frame}=[];
        
        if size(resultslist,2)>=frame
            caluv=retr('caluv');
            u=resultslistptv{4,frame}-resultslistptv{2,frame};
            v=resultslistptv{3,frame}-resultslistptv{1,frame};
            typevector_original=resultslistptv{5,frame};
            typevector=typevector_original;
            if numel(u>0)
                %velocity limits
                velrect=retr('velrect');
                if numel(velrect>0) %velocity limits were activated
                    umin=velrect(1);
                    umax=velrect(3)+umin;
                    vmin=velrect(2);
                    vmax=velrect(4)+vmin;
                    u(u*caluv<umin)=NaN;
                    u(u*caluv>umax)=NaN;
                    v(u*caluv<umin)=NaN;
                    v(u*caluv>umax)=NaN;
                    v(v*caluv<vmin)=NaN;
                    v(v*caluv>vmax)=NaN;
                    u(v*caluv<vmin)=NaN;
                    u(v*caluv>vmax)=NaN;
                end
                %manual point deletion
                manualdeletion=retr('manualdeletion');
                
                if numel(manualdeletion)>0
                    if size(manualdeletion,2)>=frame
                        if isempty(manualdeletion{1,frame}) ==0
                            framemanualdeletion=manualdeletion{frame};
                            for i=1:size(framemanualdeletion,2)
                                u(framemanualdeletion(i))=NaN;
                                v(framemanualdeletion(i))=NaN;
                                
                                %                u(manualdeletion(i,1),manualdeletion(i,2))=NaN;
                                %                v(manualdeletion(i,1),manualdeletion(i,2))=NaN;
                            end
                        end
                    end
                end
                %% stddev check
                if get(handles.stdev_check, 'value')==1
                    stdthresh=str2double(get(handles.stdev_thresh, 'String'));
                    meanu=nanmean(nanmean(u));
                    meanv=nanmean(nanmean(v));
                    std2u=nanstd(reshape(u,size(u,1)*size(u,2),1));
                    std2v=nanstd(reshape(v,size(v,1)*size(v,2),1));
                    minvalu=meanu-stdthresh*std2u;
                    maxvalu=meanu+stdthresh*std2u;
                    minvalv=meanv-stdthresh*std2v;
                    maxvalv=meanv+stdthresh*std2v;
                    u(u<minvalu)=NaN;
                    u(u>maxvalu)=NaN;
                    v(v<minvalv)=NaN;
                    v(v>maxvalv)=NaN;
                end
                %local median check
                %Westerweel & Scarano (2005): Universal Outlier detection for PIV data
                if get(handles.loc_median, 'value')==1
                    epsilon=str2double(get(handles.epsilon,'string'));
                    thresh=str2double(get(handles.loc_med_thresh,'string'));
                    [J,I]=size(u);
                    medianres=zeros(J,I);
                    normfluct=zeros(J,I,2);
                    b=1;
                    eps=0.1;
                    for c=1:2
                        if c==1; velcomp=u;else;velcomp=v;end
                        for i=1+b:I-b
                            for j=1+b:J-b
                                neigh=velcomp(j-b:j+b,i-b:i+b);
                                neighcol=neigh(:);
                                neighcol2=[neighcol(1:(2*b+1)*b+b);neighcol((2*b+1)*b+b+2:end)];
                                med=median(neighcol2);
                                fluct=velcomp(j,i)-med;
                                res=neighcol2-med;
                                medianres=median(abs(res));
                                normfluct(j,i,c)=abs(fluct/(medianres+epsilon));
                            end
                        end
                    end
                    info1=(sqrt(normfluct(:,:,1).^2+normfluct(:,:,2).^2)>thresh);
                    u(info1==1)=NaN;
                    v(info1==1)=NaN;
                end
                %0=mask
                %1=normal
                %2=manually filtered
                u(isnan(v))=NaN;
                v(isnan(u))=NaN;
                typevector(isnan(u))=2;
                typevector(isnan(v))=2;
                typevector(typevector_original==0)=0; %restores typevector for mask
                
                
                meshsize=10;% define the mesh size of the gridd in [px]
                if  isempty(roirect)==1
                    currentimage=imread(filepath{frame});
                    bordmaxx=size(currentimage,2);
                    bordmaxy=size(currentimage,1);
                    bordminx=0;
                    bordminy=0;
                else
                    bordmaxx=roirect(3)+roirect(1);
                    bordmaxy=roirect(4)+roirect(2);
                    bordminx=roirect(1);
                    bordminy=roirect(2);
                end
                
                if  isempty(roirect)==1
                    colpix=(resultslistptv{2,frame}+resultslistptv{4,frame})/2;
                    rowpix=(resultslistptv{1,frame}+resultslistptv{3,frame})/2;
                else
                    colpix=(resultslistptv{2,frame}+resultslistptv{4,frame})/2+roirect(1);
                    rowpix=(resultslistptv{1,frame}+resultslistptv{3,frame})/2+roirect(2);
                end
                vcol=resultslistptv{4,frame}-resultslistptv{2,frame};
                vrow=resultslistptv{3,frame}-resultslistptv{1,frame};
                
                xvpix=linspace(bordminx,bordmaxx,(bordmaxx-bordminx)/meshsize);
                yvpix=linspace(bordminy, bordmaxy,(bordmaxy-bordminy)/meshsize);
                [colpixinterp,rowpixinterp]=meshgrid(xvpix,yvpix);
                try
                    velcolinterp=griddata(colpix,rowpix,vcol,colpixinterp,rowpixinterp);
                    velrowinterp=griddata(colpix,rowpix,vrow,colpixinterp,rowpixinterp);
                catch
                    velcolinterp=[];
                    velrowinterp=[];
                end
                
                
                resultslist{1,frame}=colpixinterp;
                resultslist{2,frame}=rowpixinterp;
                resultslist{3,frame}=velcolinterp;
                resultslist{4,frame}=velrowinterp;
                %        resultslistptv{5,frame}=typevector;
                
                
                %interpolation using inpaint_NaNs
                %         if get(handles.interpol_missing, 'value')==1
                %             u=inpaint_nans(u,4);
                %             v=inpaint_nans(v,4);
                %         end
                resultslistptv{8, frame} = u;
                resultslistptv{7, frame} = v;
                resultslistptv{9, frame} = typevector;
                put('resultslist', resultslist);
                put('resultslistptv', resultslistptv);
            else
            end
        end
        
    end
catch
end

sliderdisp

function rejectsingle_Callback(hObject, eventdata, handles)
handles=gethand;
resultslistptv=retr('resultslistptv');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslistptv,2)>=frame %2nd dimesnion = frame
    x=resultslistptv{2,frame};
    y=resultslistptv{1,frame};
    u=resultslistptv{4,frame}-resultslistptv{2,frame};
    v=resultslistptv{3,frame}-resultslistptv{1,frame};
    %     u=resultslist{3,frame};
    %     v=resultslist{4,frame};
    typevector_original=resultslistptv{5,frame};
    typevector=typevector_original;
    manualdeletion=retr('manualdeletion');
    framemanualdeletion=[];
    if numel(manualdeletion)>0
        if size(manualdeletion,2)>=frame
            if isempty(manualdeletion{1,frame}) ==0
                framemanualdeletion=manualdeletion{frame};
            end
        end
    end
    
    if numel(u>0)
        delete(findobj(gca,'tag','manualdot'));
        text(50,10,'Right mouse button exits manual validation mode.','color','g','fontsize',8, 'BackgroundColor', 'k', 'tag', 'hint')
        toolsavailable(0);
        button = 1;
        while button == 1
            [xposition,yposition,button] = ginput(1);
            if button~=1
                break
            end
            if numel (xposition>0) %will be 0 if user presses enter
                %                 xposition=round(xposition);
                %                 yposition=round(yposition);
                imagex=[];
                findx=abs(x/xposition-1);
                %manualdeletion=zeros(size(xposition,1),2);
                for i=1:5 %five vectors with the nearest x
                    imagex=[imagex find(findx==min(findx))];
                    findx(find(findx==min(findx)))=nan;
                end
                findy=abs(y(imagex)/yposition-1);
                %                 [imagey, trash]=find(findy==min(min(findy)));
                imagey=find(findy==min(findy));
                imagey=imagex(imagey);
                
                idx=size(framemanualdeletion,2);
                %manualdeletion(idx+1,1)=imagey(1,1);
                %manualdeletion(idx+1,2)=imagex(1,1);
                
                framemanualdeletion(idx+1)=imagey;
                
                hold on;
                plot (x(framemanualdeletion(idx+1)),y(framemanualdeletion(idx+1)), 'ko', 'markerfacecolor', [0.85 0.16 0] , 'markersize', 6,'tag','manualdot')
                plot (x(framemanualdeletion(idx+1)),y(framemanualdeletion(idx+1)), 'ko', 'markerfacecolor', [0.85 0.16 0], 'markersize', 6,'tag','manualdot')
                
                hold off;
            end
        end
        manualdeletion{frame}=framemanualdeletion;
        put('manualdeletion',manualdeletion);
        
        delete(findobj(gca,'Type','text','color','r'));
        delete(findobj(gca,'tag','hint'));
        text(50,50,'Result will be shown after applying vector validation','color','r','fontsize',8, 'BackgroundColor', 'k')
    end
end
toolsavailable(1);

function draw_line_Callback(hObject, eventdata, handles)
filepath=retr('filepath');
caliimg=retr('caliimg');
if numel(caliimg)==0 && size(filepath,1) >1
    sliderdisp
end
if size(filepath,1) >1 || numel(caliimg)>0
    handles=gethand;
    toolsavailable(0)
    delete(findobj('tag', 'caliline'))
    for i=1:2
        [xposition(i),yposition(i)] = ginput(1);
        if numel(caliimg)==0
            sliderdisp
        end
        hold on;
        plot (xposition,yposition,'ro-', 'markersize', 15,'LineWidth',3, 'tag', 'caliline');
        plot (xposition,yposition,'y+:', 'tag', 'caliline');
        hold off;
        for j=1:i
            text(xposition(j)+10,yposition(j)+10, ['x:' num2str(xposition(j)) sprintf('\n') 'y:' num2str(yposition(j)) ],'color','y','fontsize',7, 'BackgroundColor', 'k', 'tag', 'caliline')
        end
        put('pointscali',[xposition' yposition']);
    end
    toolsavailable(1)
end

function calccali
put('derived',[]) %calibration makes previously derived params incorrect
put('derivedRW',[])
handles=gethand;
pointscali=retr('pointscali');
if numel(pointscali)>0
    xposition=pointscali(:,1);
    yposition=pointscali(:,2);
    dist=sqrt((xposition(1)-xposition(2))^2 + (yposition(1)-yposition(2))^2);
    realdist=str2double(get(handles.realdist, 'String'));
    time=str2double(get(handles.time_inp, 'String'));
    caluv=(realdist/(dist*1000))/time*1000;
    calxy=(realdist/1000)/dist;
    put('caluv',caluv);
    put('calxy',calxy);
    put('time',time);
    
    set(handles.calidisp, 'string', ['1 px/imagepair = ' num2str(round(caluv*1000)/1000) ' m/s'],  'backgroundcolor', [0.5 1 0.5]);
end
sliderdisp

function clear_cali_Callback(hObject, eventdata, handles)
handles=gethand;
put('pointscali',[]);
put('caluv',1);
put('calxy',1);
put('time',1);
put('caliimg', []);
filepath=retr('filepath');
set(handles.calidisp, 'string', ['inactive'], 'backgroundcolor', [0.9411764705882353 0.9411764705882353 0.9411764705882353]);
delete(findobj('tag', 'caliline'));
set(handles.realdist, 'String','1');
set(handles.time_inp, 'String','1');
if size(filepath,1) >1
    sliderdisp
else
    displogo(0)
end


function load_ext_img_Callback(hObject, eventdata, handles)
cali_folder=retr('cali_folder');
if isempty (cali_folder)==1
    if ispc==1
        cali_folder=[retr('pathname') '\'];
    else
        cali_folder=[retr('pathname') '/'];
    end
end
try
    [filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;','Image Files (*.bmp,*.tif,*.jpg)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp'; },'Select calibration image',cali_folder);
catch
    [filename, pathname, filterindex] = uigetfile({'*.bmp;*.tif;*.jpg;','Image Files (*.bmp,*.tif,*.jpg)'; '*.tif','tif'; '*.jpg','jpg'; '*.bmp','bmp'; },'Select calibration image'); %unix/mac system may cause problems, can't be checked due to lack of unix/mac systems...
end
if isequal(filename,0)==0
    caliimg=imread(fullfile(pathname, filename));
    image(caliimg, 'parent',gca, 'cdatamapping', 'scaled');
    colormap('gray');
    axis image;
    set(gca,'ytick',[])
    set(gca,'xtick',[])
    put('caliimg', caliimg);
    put('cali_folder', pathname);
end

function write_workspace_Callback(hObject, eventdata, handles)
assignin('base','results',retr('resultslist'));
assignin('base','derived',retr('derived'));
clc;
disp('first dimension of "results" is x,y,u,v,typevector,[],ufilt,vfilt,typevectorfilt,ufiltsmooth,vfiltsmooth; second dimension is the frame.')
disp('first dimension of "derived" is vorticity, velocity magnitude, u, v, divergence, DCEV, shear, strain; second dimension is the frame.')

function mean_u_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
    if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
        u=resultslist{7,currentframe};
    else
        u=resultslist{3,currentframe};
    end
    caluv=retr('caluv');
    set(handles.subtr_u, 'string', num2str(nanmean(nanmean(u*caluv))));
else
    set(handles.subtr_u, 'string', '0');
end

function mean_v_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 %analysis exists
    if size(resultslist,1)>6 && numel(resultslist{7,currentframe})>0 %filtered exists
        v=resultslist{8,currentframe};
    else
        v=resultslist{4,currentframe};
    end
    caluv=retr('caluv');
    set(handles.subtr_v, 'string', num2str(nanmean(nanmean(v*caluv))));
else
    set(handles.subtr_v, 'string', '0');
end

function derivative_calc (frame,deriv,update)
handles=gethand;
resultslist=retr('resultslist');
resultslistRW=retr('resultslistRW');
pathname=retr('pathname');
if (size(resultslist,2)>=frame && numel(resultslist{1,frame})>0 && get(handles.orthotrans,'Value')==0) ...
       || (size(resultslistRW,2)>=frame && numel(resultslistRW{1,frame})>0 && get(handles.orthotrans,'Value')==1)%analysis exists
    filenames=retr('filenames');
    filepath=retr('filepath');
    derived=retr('derived');
    derivedRW=retr('derivedRW');
    caluv=retr('caluv');
    calxy=retr('calxy');
    
    if get(handles.orthotrans,'Value')==0
        currentimage=imread(filepath{2*frame-1});
        x=resultslist{1,frame};
        y=resultslist{2,frame};
    elseif get(handles.orthotrans,'Value')==1
        currentimage=imread([ retr('PathName') 'Rectified_MEAN.jpg']);
        x=resultslistRW{1,frame};
        y=resultslistRW{2,frame};
    end
    
    
    %subtrayct mean u
    subtr_u=str2double(get(handles.subtr_u, 'string'));
    if isnan(subtr_u)
        subtr_u=0;set(handles.subtr_u, 'string', '0');
    end
    subtr_v=str2double(get(handles.subtr_v, 'string'));
    if isnan(subtr_v)
        subtr_v=0;set(handles.subtr_v, 'string', '0');
    end
    
    if get(handles.orthotrans,'Value')==0
        if size(resultslist,1)>6 && numel(resultslist{7,frame})>0 %filtered exists
            u=resultslist{7,frame};
            v=resultslist{8,frame};
            typevector=resultslist{9,frame};
        else
            u=resultslist{3,frame};
            v=resultslist{4,frame};
            %         typevector=resultslist{5,frame};
        end
    elseif get(handles.orthotrans,'Value')==1
        u=resultslistRW{3,frame};
        v=resultslistRW{4,frame};
    end
%         if get(handles.interpol_missing,'value')==1
%             if any(any(isnan(u)))==1 || any(any(isnan(v)))==1
%                 if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
%                     drawnow;
%                     msgbox('Your dataset contains NaNs. A vector interpolation will be performed automatically to interpolate missing vectors.', 'modal')
%                     uiwait
%                 end
%                 typevector_original=typevector;
%                 u(isnan(v))=NaN;
%                 v(isnan(u))=NaN;
%                 typevector(isnan(u))=2;
%                 typevector(typevector_original==0)=0;
%                 u=inpaint_nans(u,4);
%                 v=inpaint_nans(v,4);
%                 resultslist{7, frame} = u;
%                 resultslist{8, frame} = v;
%                 resultslist{9, frame} = typevector;
%             end
%         else
%             if isempty(strfind(get(handles.apply_deriv_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.ascii_all,'string'), 'Please'))==1 && isempty(strfind(get(handles.save_mat_all,'string'), 'Please'))==1%not in batch
%                 drawnow;
%                 msgbox('Your dataset contains NaNs. Derived parameters will have a lot of missing data. Redo the vector validation with the option to interpolate missing data turned on.', 'modal')
%                 uiwait
%             end
%         end
    if get(handles.smooth, 'Value') == 1
        smoothfactor=floor(get(handles.smoothstr, 'Value'));
        try
            
            u = SMOOTHN(u,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
            v = SMOOTHN(v,smoothfactor/10); %not supported in prehistoric Matlab versions like the one I have to use :'-(
            clc
            
            disp ('Using SMOOTHN.m from Damien Garcia for data smoothing.')
            
        catch
            h=fspecial('gaussian',smoothfactor+2,(smoothfactor+2)/7);
            u=imfilter(u,h,'replicate');
            v=imfilter(v,h,'replicate');
            clc
            disp ('Using Gaussian kernel for data smoothing (your Matlab version is pretty old btw...).')
        end
        if get(handles.orthotrans,'Value')==0
            resultslist{10,frame}=u; %smoothed u
            resultslist{11,frame}=v; %smoothed v
        elseif get(handles.orthotrans,'Value')==1
            resultslistRW{10,frame}=u; %smoothed u
            resultslistRW{11,frame}=v; %smoothed v
            
        end
    else
        %careful if more things are added, [] replaced by {[]}
        resultslist{10,frame}=[]; %remove smoothed u
        resultslist{11,frame}=[]; %remove smoothed v
        resultslistRW{10,frame}=[]; %remove smoothed u
        resultslistRW{11,frame}=[];
    end
    if deriv==1 %vectors only
        %do nothing
    end
    if deriv==2 %vorticity
        [curlz,cav]= curl(x*calxy,y*calxy,u*caluv,v*caluv);
        if get(handles.orthotrans,'Value')==0
            derived{1,frame}=curlz;
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{1,frame}=curlz;
        end
        
    end
    if deriv==3 %magnitude
        %andersrum, (u*caluv)-subtr_u
        if get(handles.orthotrans,'Value')==0
            derived{2,frame}=sqrt((u*caluv-subtr_u).^2+(v*caluv-subtr_v).^2);
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{2,frame}=sqrt((u*caluv-subtr_u).^2+(v*caluv-subtr_v).^2);
        end
        
    end
    if deriv==4
        if get(handles.orthotrans,'Value')==0
            derived{3,frame}=u*caluv-subtr_u;
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{3,frame}=u*caluv-subtr_u;
        end
%         
    end
    if deriv==5
        if get(handles.orthotrans,'Value')==0
            derived{4,frame}=v*caluv-subtr_v;
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{4,frame}=v*caluv-subtr_v;
        end
        
    end
    if deriv==6
        if get(handles.orthotrans,'Value')==0
            derived{5,frame}=divergence(x*calxy,y*calxy,u*caluv,v*caluv);
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{5,frame}=divergence(x*calxy,y*calxy,u*caluv,v*caluv);
        end
%         
    end
    if deriv==7
        if get(handles.orthotrans,'Value')==0
            derived{6,frame}=dcev(x*calxy,y*calxy,u*caluv,v*caluv);
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{6,frame}=dcev(x*calxy,y*calxy,u*caluv,v*caluv);
        end
        
    end
    if deriv==8
        if get(handles.orthotrans,'Value')==0
            derived{7,frame}=shear(x*calxy,y*calxy,u*caluv,v*caluv);
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{7,frame}=shear(x*calxy,y*calxy,u*caluv,v*caluv);
        end
        
    end
    if deriv==9
        if get(handles.orthotrans,'Value')==0
            derived{8,frame}=strain(x*calxy,y*calxy,u*caluv,v*caluv);
        elseif get(handles.orthotrans,'Value')==1
            derivedRW{8,frame}=strain(x*calxy,y*calxy,u*caluv,v*caluv);
        end
        
    end
    put('subtr_u', subtr_u);
    put('subtr_v', subtr_v);
    put('resultslist', resultslist);
    put('resultslistRW', resultslistRW);
    put('derived',derived);
    put('derivedRW',derivedRW);
    if update==1
        put('displaywhat', deriv);
    end
end

function apply_deriv_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
deriv=get(handles.derivchoice, 'value');
derivative_calc (currentframe,deriv,1)
sliderdisp

function out=dcev(x,y,u,v);
dUdX=conv2(u,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
    conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dVdX=conv2(v,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
    conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dUdY=conv2(u,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
    conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
dVdY=conv2(v,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
    conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
res=(dUdX+dVdY)/2+sqrt(0.25*(dUdX+dVdY).^2+dUdY.*dVdX);
d=zeros(size(x));
d(2:end-1,2:end-1)=imag(res);
out=((d/(max(max(d))-(min(min(d)))))+abs(min(min(d))))*255;%normalize

function out=strain(x,y,u,v)
hx = x(1,:);
hy = y(:,1);
[px junk] = gradient(u, hx, hy);
[junk qy] = gradient(v, hx, hy);
out = px-qy;

function out=shear(x,y,u,v)
hx = x(1,:);
hy = y(:,1);
[junk py] = gradient(u, hx, hy);
[qx junk] = gradient(v, hx, hy);
out= qx+py;

function out=rescale_maps(in)
%input has same dimensions as x,y,u,v,
%output has size of the piv image
handles=gethand;
if get(handles.orthotrans,'Value')==0
    filepath=retr('filepath');
    currentframe=floor(get(handles.fileselector, 'value'));
    currentimage=imread(filepath{2*currentframe-1});
    resultslist=retr('resultslist');
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
elseif get(handles.orthotrans,'Value')==1
    pathname=retr('pathname');
    currentframe=floor(get(handles.fileselector, 'value'));
    currentimage=imread([pathname '\Rectified_MEAN.jpg']);
    resultslistRW=retr('resultslistRW');
    x=resultslistRW{1,currentframe};
    y=resultslistRW{2,currentframe};
end
out=zeros(size(currentimage));
if size(out,3)>1
    out(:,:,2:end)=[];
end
out(:,:)=mean(mean(in));
% step=x(1,2)-x(1,1)+1;
% minx=(min(min(x))-step/2);
% maxx=(max(max(x))+step/2);
% miny=(min(min(y))-step/2);
% maxy=(max(max(y))+step/2);

minx=(min(min(x)));
maxx=(max(max(x)));
miny=(min(min(y)));
maxy=(max(max(y)));

width=maxx-minx;
height=maxy-miny;
if size(in,3)>1 %why would this actually happen...?
    in(:,:,2:end)=[];
end
dispvar = imresize(in,[height width],'bilinear');
if miny<1
    miny=1;
end
if minx<1
    minx=1;
end;
try
    out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar;
catch
    disp('temp workaround')
    A=out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1));
    out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar(1:size(A,1),1:size(A,2));
end
maskiererx=retr('maskiererx');
if numel(maskiererx)>0
    if get(handles.img_not_mask, 'value')==1 && numel(maskiererx{currentframe*2-1})>0
        maskierery=retr('maskierery');
        ximask=maskiererx{currentframe*2-1};
        yimask=maskierery{currentframe*2-1};
        BW=poly2mask(ximask,yimask,size(out,1),size(out,2));
        max_img=double(max(max(currentimage)));
        max_map=max(max(out));
        currentimage=double(currentimage)/max_img*max_map;
        out(BW==1)=currentimage(BW==1);
    end
end

function out=rescale_maps_nan(in)
%input has same dimensions as x,y,u,v,
%output has size of the ptv image
handles=gethand;

if get(handles.orthotrans,'Value')==0
    filepath=retr('filepath');
    currentframe=floor(get(handles.fileselector, 'value'));
    currentimage=imread(filepath{2*currentframe-1});
    resultslist=retr('resultslist');
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
elseif get(handles.orthotrans,'Value')==1
    pathname=retr('pathname');
    currentframe=floor(get(handles.fileselector, 'value'));
    currentimage=imread([ retr('PathName') 'Rectified_MEAN.jpg']);
    resultslistRW=retr('resultslistRW');
    x=resultslistRW{1,currentframe};
    y=resultslistRW{2,currentframe};
end

out=zeros(size(currentimage));
if size(out,3)>1
    out(:,:,2:end)=[];
end
out(:,:)=nan;
%step=x(1,2)-x(1,1);%+1;
minx=(min(min(x)));%-step/2);
maxx=(max(max(x)));%+step/2);
miny=(min(min(y)));%-step/2);
maxy=(max(max(y)));%+step/2);
width=maxx-minx;
height=maxy-miny;
if size(in,3)>1 %why would this actually happen...?
    in(:,:,2:end)=[];
end
dispvar = imresize(in,[height width],'bilinear');
if miny<1
    miny=1;
end
if minx<1
    minx=1;
end;
try
    out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar;
catch
    disp('temp workaround')
    A=out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1));
    out(floor(miny):floor(maxy-1),floor(minx):floor(maxx-1))=dispvar(1:size(A,1),1:size(A,2));
end
maskiererx=retr('maskiererx');
% if numel(maskiererx)>0
%     if numel(maskiererx{currentframe*2-1})>0
%         maskierery=retr('maskierery');
%         ximask=maskiererx{currentframe*2-1};
%         yimask=maskierery{currentframe*2-1};
%         BW=poly2mask(ximask,yimask,size(out,1),size(out,2));
%         out(BW==1)=nan;
%     end
% end


function autoscaler_Callback(hObject, eventdata, handles)
handles=gethand;
if get(handles.autoscaler, 'value')==1
    set (handles.mapscale_min, 'enable', 'off')
    set (handles.mapscale_max, 'enable', 'off')
else
    set (handles.mapscale_min, 'enable', 'on')
    set (handles.mapscale_max, 'enable', 'on')
end

function orthotrans_Callback(hObject, eventdata, handles)


function apply_cali_Callback(hObject, eventdata, handles)
calccali

function apply_deriv_all_Callback(hObject, eventdata, handles)
handles=gethand;
filepath=retr('filepath');
toolsavailable(0)
for i=1:floor(size(filepath,1)/2)+1
    deriv=get(handles.derivchoice, 'value');
    derivative_calc(i,deriv,1)
    set (handles.apply_deriv_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
    drawnow;
end
set (handles.apply_deriv_all, 'string', 'Apply to all frames');
toolsavailable(1)
sliderdisp


function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    homedir=retr('homedir');
    pathname=retr('pathname');
    dlmwrite([homedir '/last.nf'], homedir, 'delimiter', '', 'precision', 6, 'newline', 'pc')
    dlmwrite([homedir '/last.nf'], pathname, '-append', 'delimiter', '', 'precision', 6, 'newline', 'pc')
catch
end
delete(hObject);

function vectorscale_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    sliderdisp
end

function ascii_current_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    [FileName,PathName] = uiputfile('*.txt','Save vector data as...','PTVlab.txt'); %frame number in dateiname
    if isequal(FileName,0) | isequal(PathName,0)
    else
        file_save(currentframe,FileName,PathName,1);
    end
end

function ascii_all_Callback(hObject, eventdata, handles)
handles=gethand;
filepath=retr('filepath');
resultslist=retr('resultslist');
[FileName,PathName] = uiputfile('*.txt','Save vector data as...','PTVlab.txt'); %frame number in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
    toolsavailable(0)
    for i=1:floor(size(filepath,1)/2)
        i
        %if analysis exists
        if size(resultslist,2)>=i && numel(resultslist{1,i})>0
            Name=textscan(FileName,'%s%s','delimiter','.');
            FileName_nr=[char(Name{1,1}) '_' sprintf('%.4d', i) '.' char(Name{1,2})];
            file_save(i,FileName_nr,PathName,1)
            set (handles.ascii_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
            drawnow;
        end
    end
    toolsavailable(1)
    set (handles.ascii_all, 'string', 'Export all frames');
end

function save_mat_current_Callback(hObject, eventdata, handles)
handles=gethand;
if get(handles.orthotrans,'Value')==0
    resultslist=retr('resultslist');
elseif get(handles.orthotrans,'Value')==1
    resultslist=retr('resultslistRW');
end
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    [FileName,PathName] = uiputfile('*.mat','Save MATLAB file as...','PTVlab.mat'); %framenummer in dateiname
    if isequal(FileName,0) | isequal(PathName,0)
    else
        file_save(currentframe,FileName,PathName,2);
    end
end

function save_mat_all_Callback(hObject, eventdata, handles)
handles=gethand;
filepath=retr('filepath');
if get(handles.orthotrans,'Value')==0
    resultslist=retr('resultslist');
elseif get(handles.orthotrans,'Value')==1
    resultslist=retr('resultslistRW');
end
[FileName,PathName] = uiputfile('*.mat','Save MATLAB file as...','PTVlab.mat'); %framenummer in dateiname
if isequal(FileName,0) | isequal(PathName,0)
else
    toolsavailable(0)
    for i=1:floor(size(filepath,1)/2)
        %if analysis exists
        if size(resultslist,2)>=i && numel(resultslist{1,i})>0
            Name=textscan(FileName,'%s%s','delimiter','.');
            FileName_nr=[char(Name{1,1}) '_' sprintf('%.4d', i) '.' char(Name{1,2})];
            file_save(i,FileName_nr,PathName,2)
            set (handles.save_mat_all, 'string', ['Please wait... (' int2str((i-1)/size(filepath,1)*200) '%)']);
            drawnow;
        end
    end
    toolsavailable(1)
    set (handles.save_mat_all, 'string', 'Save all frames');
end

% --- Executes on button press in set_points.
function set_points_Callback(hObject, eventdata, handles)
sliderdisp
hold on;
toolsavailable(0)
delete(findobj('tag', 'measure'));
n=0;
for i=1:2
    [xi,yi,but] = ginput(1);
    n=n+1;
    xposition(n)=xi;
    yposition(n)=yi;
    plot(xposition(n),yposition(n), 'r*','Color', [0.55,0.75,0.9], 'tag', 'measure');
    line(xposition,yposition,'LineWidth',3, 'Color', [0.05,0,0], 'tag', 'measure');
    line(xposition,yposition,'LineWidth',1, 'Color', [0.05,0.75,0.05], 'tag', 'measure');
end
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',3, 'Color', [0.05,0.0,0.0], 'tag', 'measure');
line([xposition(1,1) xposition(1,2)],[yposition(1,1) yposition(1,1)], 'LineWidth',1, 'Color', [0.95,0.05,0.01], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',3, 'Color',[0.05,0.0,0], 'tag', 'measure');
line([xposition(1,2) xposition(1,2)], yposition,'LineWidth',1, 'Color',[0.35,0.35,1], 'tag', 'measure');
hold off;
toolsavailable(1)
deltax=abs(xposition(1,1)-xposition(1,2));
deltay=abs(yposition(1,1)-yposition(1,2));
length=sqrt(deltax^2+deltay^2);
alpha=(180/pi) *(acos(deltax/length));
beta=(180/pi) *(asin(deltax/length));
handles=gethand;
calxy=retr('calxy');
set (handles.deltax, 'String', num2str(deltax*calxy));
set (handles.deltay, 'String', num2str(deltay*calxy));
set (handles.length, 'String', num2str(length*calxy));
set (handles.alpha, 'String', num2str(alpha));
set (handles.beta, 'String', num2str(beta));

% --- Executes on button press in draw_stuff.
function draw_stuff_Callback(hObject, eventdata, handles)
sliderdisp;
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
resultslistRW=retr('resultslistRW');
if (size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 && get(handles.orthotrans,'Value')==0) ...
        || (size(resultslistRW,2)>=currentframe && numel(resultslistRW{1,currentframe})>0 && get(handles.orthotrans,'Value')==1) 

    toolsavailable(0);
    xposition=[];
    yposition=[];
    n = 0;
    but = 1;
    hold on;
    if get(handles.draw_what,'value')==1 %polyline
        while but == 1
            [xi,yi,but] = ginput(1);
            if but~=1
                break
            end
            delete(findobj('tag', 'extractpoint'))
            plot(xi,yi,'r+','tag','extractpoint')
            n = n+1;
            xposition(n)=xi;
            yposition(n)=yi;
            delete(findobj('tag', 'extractline'))
            delete(findobj('tag','areaint'));
            line(xposition,yposition,'LineWidth',3, 'Color', [0,0,0.95],'tag','extractline');
            line(xposition,yposition,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','extractline');
        end
    elseif get(handles.draw_what,'value')==2 %circle
        for i=1:2
            [xi,yi,but] = ginput(1);
            if i==1;delete(findobj('tag', 'extractpoint'));end
            n=n+1;
            xposition_raw(n)=xi;
            yposition_raw(n)=yi;
            plot(xposition_raw(n),yposition_raw(n), 'r+', 'MarkerSize',10,'tag','extractpoint');
        end
        deltax=abs(xposition_raw(1,1)-xposition_raw(1,2));
        deltay=abs(yposition_raw(1,1)-yposition_raw(1,2));
        radius=sqrt(deltax^2+deltay^2);
        valtable=linspace(0,2*pi,361);
        for i=1:size(valtable,2)
            xposition(1,i)=sin(valtable(1,i))*radius+xposition_raw(1,1);
            yposition(1,i)=cos(valtable(1,i))*radius+yposition_raw(1,1);
        end
        delete(findobj('tag', 'extractline'))
        line(xposition,yposition,'LineWidth',3, 'Color', [0,0,0.95],'tag','extractline');
        line(xposition,yposition,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','extractline');
        text(xposition(1,1),yposition(1,1),'\leftarrow start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(1,1),yposition(1,1)+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(1,1),yposition(1,1)-8-radius*2,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(1,1)-radius-8,yposition(1,1)-radius,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
        text(xposition(1,1)+radius+8,yposition(1,1)-radius,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
    elseif get(handles.draw_what,'value')==3 %circle series
        set(handles.extraction_choice,'Value',9);
        for i=1:2
            [xi,yi,but] = ginput(1);
            if i==1;delete(findobj('tag', 'extractpoint'));end
            n=n+1;
            xposition_raw(n)=xi;
            yposition_raw(n)=yi;
            plot(xposition_raw(n),yposition_raw(n), 'r+', 'MarkerSize',10,'tag','extractpoint');
        end
        deltax=abs(xposition_raw(1,1)-xposition_raw(1,2));
        deltay=abs(yposition_raw(1,1)-yposition_raw(1,2));
        radius=sqrt(deltax^2+deltay^2);
        valtable=linspace(0,2*pi,361);
        for m=1:30
            for i=1:size(valtable,2)
                xposition(m,i)=sin(valtable(1,i))*(radius-((30-m)/30)*radius)+xposition_raw(1,1);
                yposition(m,i)=cos(valtable(1,i))*(radius-((30-m)/30)*radius)+yposition_raw(1,1);
            end
        end
        delete(findobj('tag', 'extractline'))
        for m=1:30
            line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
        end
        text(xposition(30,1),yposition(30,1),'\leftarrow start/end','FontSize',7, 'Rotation', 90, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(30,1),yposition(30,1)+8,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(30,1),yposition(30,1)-8-radius*2,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1],'tag','extractline')
        text(xposition(30,1)-radius-8,yposition(30,1)-radius,'\leftarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
        text(xposition(30,1)+radius+8,yposition(30,1)-radius,'\rightarrow','FontSize',7, 'BackgroundColor',[1 1 1], 'Rotation', 90,'tag','extractline')
    end
    hold off;
    put('xposition',xposition)
    put('yposition',yposition)
    toolsavailable(1);
end


function draw_point_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
resultslistRW=retr('resultslistRW');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame    %2nd dimesnion = frame
    
    if get(handles.orthotrans,'Value')==0
        x=resultslist{1,frame};
        x=x(1,:)';
        y=resultslist{2,frame};
        y=y(:,1);
        
    elseif get(handles.orthotrans,'Value')==1
        x=resultslistRW{1,frame};
        x=x(1,:)';
        y=resultslistRW{2,frame};
        y=y(:,1);
    end

    manualpoint=retr('manualpoint');
    delete(findobj(gca,'tag','manualdot'));
    text(50,10,'Right mouse button exits manual validation mode.','color','g','fontsize',8, 'BackgroundColor', 'k', 'tag', 'hint')
    toolsavailable(0);
    button = 1;
    while button == 1
        [xposition,yposition,button] = ginput(1);
        if button~=1
            break
        end
        if numel (xposition>0) %will be 0 if user presses enter
            findx=abs(x/xposition-1);
            imagex=find(findx==min(findx));
            findy=abs(y/yposition-1);
            imagey=find(findy==min(findy));
            
            idx=size(manualpoint,1);
            manualpoint(idx+1,1)=imagex;
            manualpoint(idx+1,2)=imagey;
            hold on;
            plot (x(manualpoint(idx+1,1)),y(manualpoint(idx+1,2)), 'ko', 'markerfacecolor', [0.68 0.92 1], 'markersize', 6,'tag','manualdot')
            
            hold off;
        end
    end
end
put('manualpoint',manualpoint);

delete(findobj(gca,'Type','text','color','r'));
delete(findobj(gca,'tag','hint'));

toolsavailable(1);




% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
resultslistRW=retr('resultslistRW');
currentframe=floor(get(handles.fileselector, 'value'));
if (size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 && get(handles.orthotrans,'Value')==0) ...
        || (size(resultslistRW,2)>=currentframe && numel(resultslistRW{1,currentframe})>0 && get(handles.orthotrans,'Value')==1) 
    delete(findobj('tag', 'derivplotwindow'));
    plot_data_Callback %make sure that data was calculated
    extractwhat=get(handles.extraction_choice,'Value');
    current=get(handles.extraction_choice,'string');
    current=current{extractwhat};
    [FileName,PathName] = uiputfile('*.txt','Save extracted data as...',['PTVlab_Extr_' current '_' num2str(currentframe) '.txt']); %framenummer in dateiname
    if isequal(FileName,0) | isequal(PathName,0)
    else
        c=retr('c');
        distance=retr('distance');
        if size(c,2)>1
            header=['circle nr.,' 'Distance on line,' current];
            wholeLOT=[];
            for z=1:30
                wholeLOT=[wholeLOT;[linspace(z,z,size(c,2))' distance(z,:)' c(z,:)']]; %anders.... untereinander
            end
        else
            header=['Distance on line,' current];
            wholeLOT=[distance c];
        end
        fid = fopen(fullfile(PathName,FileName), 'w');
        fprintf(fid, [header '\r\n']);
        fclose(fid);
        dlmwrite(fullfile(PathName,FileName), wholeLOT, '-append', 'delimiter', ',', 'precision', 10, 'newline', 'pc');
    end
end

function save_data_point_Callback(hObject, eventdata, handles)
handles=gethand;
all_point_parameter=retr('all_point_parameter');
all_point=retr('all_point');
extractwhat=get(handles.extraction_point_choice,'Value');
current=get(handles.extraction_point_choice,'string');
current=current{extractwhat};
header=[ all_point current];
[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',['PTVlab_Extr_' current  '.txt']);
fid = fopen(fullfile(PathName,FileName), 'w');
fprintf(fid, [header '\r\n']);
fclose(fid);
dlmwrite(fullfile(PathName,FileName), all_point_parameter, '-append', 'delimiter', ',', 'precision', 10, 'newline', 'pc');


% --- Executes on button press in plot_data.
function plot_data_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
resultslistRW=retr('resultslistRW');
if (size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0 && get(handles.orthotrans,'Value')==0)...
       || (size(resultslistRW,2)>=currentframe && numel(resultslistRW{1,currentframe})>0 && get(handles.orthotrans,'Value')==1)
    
    if get(handles.orthotrans,'Value')==0
        x=resultslist{1,currentframe};
        y=resultslist{2,currentframe};
    elseif get(handles.orthotrans,'Value')==1
        x=resultslistRW{1,currentframe};
        y=resultslistRW{2,currentframe};
    end
    
    xposition=retr('xposition'); %not conflicting...?
    yposition=retr('yposition'); %not conflicting...?
    if numel(xposition)>1
        for i=1:size(xposition,2)-1
            %length of one segment:
            laenge(i)=sqrt((xposition(1,i+1)-xposition(1,i))^2+(yposition(1,i+1)-yposition(1,i))^2);
        end
        length=sum(laenge);
        percentagex=xposition/max(max(x));
        xaufderivative=percentagex*size(x,2);
        percentagey=yposition/max(max(y));
        yaufderivative=percentagey*size(y,1);
        nrpoints=str2num(get(handles.nrpoints,'string'));
        if get(handles.draw_what,'value')==3 %circle series
            set(handles.extraction_choice,'Value',9); %set to tangent
        end
        extractwhat=get(handles.extraction_choice,'Value');
        switch extractwhat
            case {1,2,3,4,5,6,7,8}
                derivative_calc(currentframe,extractwhat+1,0);
                if get(handles.orthotrans,'Value')==0
                    derived=retr('derived');                    
                    maptoget=derived{extractwhat,currentframe};
                elseif get(handles.orthotrans,'Value')==1
                    derivedRW=retr('derivedRW');
                    maptoget=derivedRW{extractwhat,currentframe};
                end
                maptoget=rescale_maps_nan(maptoget);
                [cx, cy, c] = improfile(maptoget,xposition,yposition,round(nrpoints),'bicubic');
                
                distance=linspace(0,length,size(c,1))';
                
            case 9 %tangent
                if size(xposition,1)<=1 %user did not choose circle series
                    if size(resultslist,1)>6 %filtered exists
                        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
                            u=resultslist{10,currentframe};
                            v=resultslist{11,currentframe};
                            typevector=resultslist{9,currentframe};
                            if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
                                typevector=resultslist{5,currentframe};
                            end
                        else
                            u=resultslist{7,currentframe};
                            if size(u,1)>1
                                v=resultslist{8,currentframe};
                                typevector=resultslist{9,currentframe};
                            else
                                u=resultslist{3,currentframe};
                                v=resultslist{4,currentframe};
                                typevector=resultslist{5,currentframe};
                            end
                        end
                    else
                        u=resultslist{3,currentframe};
                        v=resultslist{4,currentframe};
                        typevector=resultslist{5,currentframe};
                    end
                    caluv=retr('caluv');
                    u=u*caluv-retr('subtr_u');
                    v=v*caluv-retr('subtr_v');
                    
                    u=rescale_maps_nan(u);
                    v=rescale_maps_nan(v);
                    
                    [cx, cy, cu] = improfile(u,xposition,yposition,round(nrpoints),'bicubic');
                    cv = improfile(v,xposition,yposition,round(nrpoints),'bicubic');
                    cx=cx';
                    cy=cy';
                    deltax=zeros(1,size(cx,2)-1);
                    deltay=zeros(1,size(cx,2)-1);
                    laenge=zeros(1,size(cx,2)-1);
                    alpha=zeros(1,size(cx,2)-1);
                    sinalpha=zeros(1,size(cx,2)-1);
                    cosalpha=zeros(1,size(cx,2)-1);
                    for i=2:size(cx,2)
                        deltax(1,i)=cx(1,i)-cx(1,i-1);
                        deltay(1,i)=cy(1,i)-cy(1,i-1);
                        laenge(1,i)=sqrt(deltax(1,i)*deltax(1,i)+deltay(1,i)*deltay(1,i));
                        alpha(1,i)=(acos(deltax(1,i)/laenge(1,i)));
                        if deltay(1,i) < 0
                            sinalpha(1,i)=sin(alpha(1,i));
                        else
                            sinalpha(1,i)=sin(alpha(1,i))*-1;
                        end
                        cosalpha(1,i)=cos(alpha(1,i));
                    end
                    sinalpha(1,1)=sinalpha(1,2);
                    cosalpha(1,1)=cosalpha(1,2);
                    cu=cu.*cosalpha';
                    cv=cv.*sinalpha';
                    c=cu-cv;
                    cx=cx';
                    cy=cy';
                    distance=linspace(0,length,size(cu,1))';
                else %user chose circle series
                    for m=1:30
                        for i=1:size(xposition,2)-1
                            %length of one segment:
                            laenge(m,i)=sqrt((xposition(m,i+1)-xposition(m,i))^2+(yposition(m,i+1)-yposition(m,i))^2);
                        end
                        length(m)=sum(laenge(m,:));
                    end
                    if size(resultslist,1)>6 %filtered exists
                        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
                            u=resultslist{10,currentframe};
                            v=resultslist{11,currentframe};
                            typevector=resultslist{9,currentframe};
                            if numel(typevector)==0%happens if user smoothes sth without NaN and without validation
                                typevector=resultslist{5,currentframe};
                            end
                        else
                            u=resultslist{7,currentframe};
                            if size(u,1)>1
                                v=resultslist{8,currentframe};
                                typevector=resultslist{9,currentframe};
                            else
                                u=resultslist{3,currentframe};
                                v=resultslist{4,currentframe};
                                typevector=resultslist{5,currentframe};
                            end
                        end
                    else
                        u=resultslist{3,currentframe};
                        v=resultslist{4,currentframe};
                        typevector=resultslist{5,currentframe};
                    end
                    caluv=retr('caluv');
                    u=u*caluv-retr('subtr_u');
                    v=v*caluv-retr('subtr_v');
                    u=rescale_maps_nan(u);
                    v=rescale_maps_nan(v);
                    min_y=floor(min(min(yposition)))-1;
                    max_y=ceil(max(max(yposition)))+1;
                    min_x=floor(min(min(xposition)))-1;
                    max_x=ceil(max(max(xposition)))+1;
                    if min_y<1
                        min_y=1;
                    end
                    if max_y>size(u,1)
                        max_y=size(u,1);
                    end
                    if min_x<1
                        min_x=1;
                    end
                    if max_x>size(u,2)
                        max_x=size(u,2);
                    end
                    
                    uc=u(min_y:max_y,min_x:max_x);
                    vc=v(min_y:max_y,min_x:max_x);
                    for m=1:30
                        [cx(m,:),cy(m,:),cu(m,:)] = improfile(uc,xposition(m,:)-min_x,yposition(m,:)-min_y,100,'nearest');
                        cv(m,:) =improfile(vc,xposition(m,:)-min_x,yposition(m,:)-min_y,100,'nearest');
                    end
                    deltax=zeros(1,size(cx,2)-1);
                    deltay=zeros(1,size(cx,2)-1);
                    laenge=zeros(1,size(cx,2)-1);
                    alpha=zeros(1,size(cx,2)-1);
                    sinalpha=zeros(1,size(cx,2)-1);
                    cosalpha=zeros(1,size(cx,2)-1);
                    for m=1:30
                        for i=2:size(cx,2)
                            deltax(m,i)=cx(m,i)-cx(m,i-1);
                            deltay(m,i)=cy(m,i)-cy(m,i-1);
                            laenge(m,i)=sqrt(deltax(m,i)*deltax(m,i)+deltay(m,i)*deltay(m,i));
                            alpha(m,i)=(acos(deltax(m,i)/laenge(m,i)));
                            if deltay(m,i) < 0
                                sinalpha(m,i)=sin(alpha(m,i));
                            else
                                sinalpha(m,i)=sin(alpha(m,i))*-1;
                            end
                            cosalpha(m,i)=cos(alpha(m,i));
                        end
                        sinalpha(m,1)=sinalpha(m,2); %ersten winkel füllen
                        cosalpha(m,1)=cosalpha(m,2);
                    end
                    cu=cu.*cosalpha;
                    cv=cv.*sinalpha;
                    c=cu-cv;
                    for m=1:30
                        distance(m,:)=linspace(0,length(m),size(cu,2))'; %in pixeln...
                    end
                end
                
        end
        if size(xposition,1)<=1 %user did not choose circle series
            h=figure;
            screensize=get( 0, 'ScreenSize' );
            rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
            set(h,'position', rect);
            current=get(handles.extraction_choice,'string');
            current=current{extractwhat};
            set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
            calxy=retr('calxy');
            integral=trapz(distance*calxy,c);
            h2=plot(distance*calxy,c);
            text(0+0.05*max(distance*calxy),min(c)+0.05*max(c),['Integral = ' num2str(integral)], 'BackgroundColor', 'w')
            set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
            xlabel('Distance on line');
            ylabel(current);
            put('distance',distance*calxy);
            put('c',c);
            h_extractionplot=retr('h_extractionplot');
            h_extractionplot(size(h_extractionplot,1)+1,1)=h;
            put ('h_extractionplot', h_extractionplot);
        else %user chose circle series
            calxy=retr('calxy');
            for m=1:30
                integral(m)=trapz(distance(m,:)*calxy,c(m,:));
            end
            %highlight circle with highest circ
            delete(findobj('tag', 'extractline'))
            for m=1:30
                line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
            end
            [r,col]=find(max(abs(integral))==abs(integral)); %find absolute max of integral
            line(xposition(col,:),yposition(col,:),'LineWidth',2.5, 'Color', [0.2,0.5,0.7],'tag','extractline');
            h=figure;
            screensize=get( 0, 'ScreenSize' );
            rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
            set(h,'position', rect);
            current=get(handles.extraction_choice,'string');
            current=current{extractwhat};
            set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
            hold on;
            for m=1:30
                h2=plot(distance(m,:)*calxy,c(m,:), 'color',[m/30, rand(1)/4+0.5, 1-m/30]);
            end
            hold off;
            set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
            xlabel('Distance on line');
            ylabel(current);
            h3=figure;
            screensize=get( 0, 'ScreenSize' );
            rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
            set(h3,'position', rect);
            current=get(handles.extraction_choice,'string');
            current=current{extractwhat};
            set(h3,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ', frame ' num2str(currentframe)],'tag', 'derivplotwindow');
            calxy=retr('calxy');
            %user can click on point, circle will be displayed in main window
            plot (1:30, integral);
            hold on;
            scattergroup1=scatter(1:30, integral, 80, 'ko');
            hold off;
            set(scattergroup1, 'ButtonDownFcn', @hitcircle, 'hittestarea', 'off');
            title('Click the points of the graph to highlight it''s corresponding circle.')
            set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
            xlabel('circle series nr. (circle with max. circulation highlighted in blue)');
            ylabel('tangent velocity loop integral (circulation)');
            put('distance',distance*calxy);
            put('c',c);
            put('h3plot', h3);
            put('integral', integral);
            h_extractionplot=retr('h_extractionplot');
            h_extractionplot(size(h_extractionplot,1)+1,1)=h;
            put ('h_extractionplot', h_extractionplot);
            h_extractionplot2=retr('h_extractionplot2');
            h_extractionplot2(size(h_extractionplot2,1)+1,1)=h3;
            put ('h_extractionplot2', h_extractionplot2);
        end
    end
end

% --- Executes on button press in plot_data_point.
function plot_data_point_Callback(hObject, eventdata, handles)
handles=gethand;
resultslist=retr('resultslist');
resultslistptv=retr('resultslistptv');
manualpoint=retr('manualpoint');
extractwhat=get(handles.extraction_point_choice,'Value');
caluv=retr('caluv');
time=retr('time');
U=retr('BIGU');
V=retr('BIGV');
sequencer=retr('sequencer');
t=0:length(resultslistptv)-1;
t=(t*time)/1000;
if sequencer==1 %sequencing 1-2, 3-4, 5-6 instead of 1-2, 2-3, 3-4...
    t=t*2;
end
resultspoints=[];
if isempty(manualpoint)==0 && length(resultslist)~=0
    if length(U)~= length(resultslist)
        for i=1:length(resultslistptv)
            if isempty(resultslist{3,i})==0
                U(:,:,i)=resultslist{3,i};
                V(:,:,i)=resultslist{4,i};
            else
                U(:,:,i)=nan*ones(size(U,1),size(U,2));
                V(:,:,i)=U(:,:,i);
            end
            set(handles.plot_data_point, 'string' , [int2str((i+1)/(length(resultslist))*100) '%'],...
                'ForegroundColor', [0.502 0.502 0.502])
            drawnow
        end
    end
    put('BIGU',U)
    put('BIGV',V)
    set(handles.plot_data_point, 'string' , 'Plot data',...
        'ForegroundColor', [0 0 0])
    % plot all the results
    choice=get(handles.extraction_point_choice,'value');
    all_point_parameter=[];
    all_point =[];
    for j=1:size(manualpoint,1)
        h=figure;
        u=reshape(U(manualpoint(j,2),manualpoint(j,1),:),length(resultslistptv),1);
        v=reshape(V(manualpoint(j,2),manualpoint(j,1),:),length(resultslistptv),1);
        u=u*caluv-retr('subtr_u');
        v=v*caluv-retr('subtr_v');
        
        if choice==1
            mag=(u.^2+v.^2).^0.5;
            parameter_point=mag;
        end
        if choice==2
            parameter_point=u;
        end
        if choice==3
            parameter_point=v;
        end
        plot(t,parameter_point,'Color',[0.04 0.52 0.78],'Marker','o', ...
            'markerfacecolor', [0.04 0.52 0.78], 'markersize', 3,'tag','manualdot')
        hold on
        meanpar=nanmean(parameter_point);
        plot(t,ones(length(parameter_point))*nanmean(parameter_point),'r')
        title('Normalized data density in the whole session')
        
        
        screensize=get( 0, 'ScreenSize' );
        rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
        set(h,'position', rect);
        current=get(handles.extraction_point_choice,'string');
        current=current{extractwhat};
        set(h,'numbertitle','off','menubar','none','toolbar','figure',...
            'dockcontrols','off','name',[current ', point # ' num2str(j) ],'tag', 'velocityhistory');
        text(0.01,meanpar,['Mean = ' num2str(meanpar)], ...
            'BackgroundColor', 'w','Color',[0.85 0.16 0])
        set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in','XLim',[0 t(end)] )
        xlabel('Time');
        ylabel(current);
        
        % make matrix to save the results
        all_point_parameter=[all_point_parameter parameter_point];
        all_point=[all_point ['point # ' num2str(j) ', ']];
        put('all_point_parameter',all_point_parameter)
        put('all_point',all_point)
        
    end
end



function hitcircle(src,eventdata)
posreal=get(gca,'CurrentPoint');
delete(findobj('tag','circstring'));
pos=round(posreal(1,1));
xposition=retr('xposition');
yposition=retr('yposition');
integral=retr('integral');
hgui=getappdata(0,'hgui');
h3plot=retr('h3plot');
figure(hgui);
delete(findobj('tag', 'extractline'))
for m=1:30
    line(xposition(m,:),yposition(m,:),'LineWidth',1.5, 'Color', [0.95,0.5,0.01],'tag','extractline');
end
line(xposition(pos,:),yposition(pos,:),'LineWidth',2.5, 'Color',[0.2,0.5,0.7],'tag','extractline');
figure(h3plot);
marksize=linspace(80,80,30)';
marksize(pos)=150;
set(gco, 'SizeData', marksize);
text(posreal(1,1)+0.75,posreal(2,2),['\leftarrow ' num2str(integral(pos))],'tag','circstring','BackgroundColor', [1 1 1], 'margin', 0.01, 'fontsize', 7, 'HitTest', 'off')

% --- Executes on button press in clear_plot.
function clear_plot_Callback(hObject, eventdata, handles)
h_extractionplot=retr('h_extractionplot');
h_extractionplot2=retr('h_extractionplot2');
for i=1:size(h_extractionplot,1)
    try
        close (h_extractionplot(i));
    catch
    end
    try
        close (h_extractionplot2(i));
    catch
    end
end
put ('h_extractionplot', []);
put ('h_extractionplot2', []);
delete(findobj('tag', 'extractpoint'));
delete(findobj('tag', 'extractline'));
delete(findobj('tag', 'circstring'));

% --- Executes on button press in clear_plot.
function clear_cpoints_Callback(hObject, eventdata, handles)
manualpoint=retr('manualpoint');
% h_extractionplot=retr('h_extractionplot');
% h_extractionplot2=retr('h_extractionplot2');
% for i=1:size(h_extractionplot,1)
%     try
%         close (h_extractionplot(i));
%     catch
%     end
%     try
%         close (h_extractionplot2(i));
%     catch
%     end
% end
put('manualpoint', []);
% % put ('h_extractionplot2', []);
% delete(findobj('tag', 'extractpoint'));
% delete(findobj('tag', 'extractline'));
delete(findobj('tag', 'manualdot'));

% --- Executes on button press in histdraw.
function histdraw_Callback(hObject, eventdata, handles)
handles=gethand;

choice_plot=get(handles.hist_select,'value');
current=get(handles.hist_select,'string');
current=current{choice_plot};


%if analys existing
resultslist=retr('resultslist');
resultslistptv=retr('resultslistptv');
handles=gethand;
currentframe=2*floor(get(handles.fileselector, 'value'))-1;
if size(resultslist,2)>=(currentframe+1)/2 %data for current frame exists
    x=resultslistptv{2,(currentframe+1)/2};
    y=resultslistptv{1,(currentframe+1)/2};
    
    if size(x,1)>1
        %         if get(handles.meanofall,'value')==1 %calculating mean doesn't mae sense...
        for i=1:size(resultslistptv,2)
            if isempty(resultslistptv{1,i})==1
                alllength(i)=0;
            else
                alllength(i)=length(resultslistptv{1,i});
            end
        end
        maxlength=nanmax(alllength);
        for i=1:size(resultslistptv,2)
            u(:,i)=[resultslistptv{4,i}-resultslistptv{2,i}; nan*ones(maxlength-alllength(i),1)];
            v(:,i)=[resultslistptv{3,i}-resultslistptv{1,i}; nan*ones(maxlength-alllength(i),1)];%
        end
        
        velrect=retr('velrect');
        caluv=retr('caluv');
        if numel(velrect>0)
            %user already selected window before...
            %"filter u+v" and display scatterplot
            %problem: if user selects limits and then wants to refine vel
            %limits, all data is filterd out...
            umin=velrect(1);
            umax=velrect(3)+umin;
            vmin=velrect(2);
            vmax=velrect(4)+vmin;
            %             %check if all results are nan...
            %
            u_backup=u;
            v_backup=v;
            u(u*caluv<umin)=NaN;
            u(u*caluv>umax)=NaN;
            v(u*caluv<umin)=NaN;
            v(u*caluv>umax)=NaN;
            v(v*caluv<vmin)=NaN;
            v(v*caluv>vmax)=NaN;
            u(v*caluv<vmin)=NaN;
            u(v*caluv>vmax)=NaN;
            
        end
        datau=reshape(u*caluv,1,size(u,1)*size(u,2));
        datav=reshape(v*caluv,1,size(v,1)*size(v,2));
        
    end
end

h=figure;
screensize=get( 0, 'ScreenSize' );
rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
set(h,'position', rect);
set(h,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',['Histogram ' current ],'tag', 'derivplotwindow');
nrofbins=str2double(get(handles.nrofbins, 'string'));
if choice_plot==1
    [n xout]=hist(datau-retr('subtr_u'),nrofbins);
    xdescript='velocity (u)';
elseif choice_plot==2
    [n xout]=hist(datav-retr('subtr_v'),nrofbins);
    xdescript='velocity (v)';
elseif choice_plot==3
    [n xout]=hist(sqrt((datau-retr('subtr_u')).^2+(datav-retr('subtr_v')).^2),nrofbins);
    xdescript='velocity magnitude';
end
h2=bar(xout,n);
set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
xlabel(xdescript);
ylabel('frequency');


% --- Executes on button press in generate_it.
function generate_it_Callback(hObject, eventdata, handles)
handles=gethand;
flow_sim=get(handles.flow_sim,'value');
switch flow_sim
    case 1 %rankine
        v0 = str2double(get(handles.rank_displ,'string')); %max velocity
        vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
        center1=[str2double(get(handles.rankx1,'string')),str2double(get(handles.ranky1,'string'))]; %x,y
        center2=[str2double(get(handles.rankx2,'string')),str2double(get(handles.ranky2,'string'))]; %x,y
        [x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
        [o,r] = cart2pol(x,y);
        uo=zeros(size(x));
        R0 = str2double(get(handles.rank_core,'string')); %radius %35
        uoin = (r <= R0);
        uout = (r > R0);
        uo = uoin+uout;
        uo(uoin) =  v0*r(uoin)/R0;
        uo(uout) =  v0*R0./r(uout);
        uo(isnan(uo))=0;
        u = -uo.*sin(o);
        v = uo.*cos(o);
        if get(handles.singledoublerankine,'value')==2
            [x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
            [o,r] = cart2pol(x,y);
            uo=zeros(size(x));
            R0 = str2double(get(handles.rank_core,'string')); %radius %35
            uoin = (r <= R0);
            uout = (r > R0);
            uo = uoin+uout;
            uo(uoin) =  v0*r(uoin)/R0;
            uo(uout) =  v0*R0./r(uout);
            uo(isnan(uo))=0;
            u2 = -uo.*sin(o);
            v2 = uo.*cos(o);
            u=u-u2;
            v=v-v2;
        end
    case 2 %oseen
        v0 = str2double(get(handles.oseen_displ,'string'))*3; %max velocity
        vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
        center1=[str2double(get(handles.oseenx1,'string')),str2double(get(handles.oseeny1,'string'))]; %x,y
        center2=[str2double(get(handles.oseenx2,'string')),str2double(get(handles.oseeny2,'string'))]; %x,y
        [x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
        [o,r] = cart2pol(x,y);
        uo=zeros(size(x));
        zaeh=1;
        t=str2double(get(handles.oseen_time,'string'));
        r=r/100;
        
        %uo wird im zwentrum NaN!!
        uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
        uo(isnan(uo))=0;
        u = -uo.*sin(o);
        v = uo.*cos(o);
        
        if get(handles.singledoubleoseen,'value')==2
            [x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
            [o,r] = cart2pol(x,y);
            r=r/100;
            uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
            uo(isnan(uo))=0;
            u2 = -uo.*sin(o);
            v2 = uo.*cos(o);
            u=u-u2;
            v=v-v2;
        end
    case 3 %linear
        u=zeros(str2double(get(handles.img_sizey,'string')),str2double(get(handles.img_sizex,'string')));
        v(1:str2double(get(handles.img_sizey,'string')),1:str2double(get(handles.img_sizex,'string')))=str2double(get(handles.shiftdisplacement,'string'));
    case 4 % rotation
        [v,u] = meshgrid(-(str2double(get(handles.img_sizex,'string')))/2:1:(str2double(get(handles.img_sizex,'string')))/2-1,-(str2double(get(handles.img_sizey,'string')))/2:1:(str2double(get(handles.img_sizey,'string')))/2-1);
        
        u=u/max(max(u));
        v=-v/max(max(v));
        u=u*str2double(get(handles.rotationdislacement,'string'));
        v=v*str2double(get(handles.rotationdislacement,'string'));
        [x,y]=meshgrid(1:1:str2double(get(handles.img_sizex,'string'))+1);
    case 5 %membrane
        [x,y]=meshgrid(linspace(-3,3,str2double(get(handles.img_sizex,'string'))),linspace(-3,3,str2double(get(handles.img_sizey,'string'))));
        u = peaks(x,y)/3;
        v = peaks(y,x)/3;
end
%% Create Particle Image
set(handles.status_creation,'string','Calculating particles...');drawnow;
i=[];
j=[];
sizey=str2double(get(handles.img_sizey,'string'));
sizex=str2double(get(handles.img_sizex,'string'));
noise=str2double(get(handles.part_noise,'string'));
A=zeros(sizey,sizex);
B=A;
partAm=str2double(get(handles.part_am,'string'));
Z=str2double(get(handles.sheetthick,'string')); %0.25 sheet thickness
dt=str2double(get(handles.part_size,'string')); %particle diameter
ddt=str2double(get(handles.part_var,'string')); %particle diameter variation

z0_pre=randn(partAm,1); %normal distributed sheet intensity
randn('state', sum(100*clock));
z1_pre=randn(partAm,1); %normal distributed sheet intensity

z0=z0_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z1_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));
z1=z1_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z0_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));

%z0=abs(randn(partAm,1)); %normal distributed sheet intensity
I0=255*exp(-(Z^2./(0.125*z0.^2))); %particle intensity
I0(I0>255)=255;
I0(I0<0)=0;

I1=255*exp(-(Z^2./(0.125*z1.^2))); %particle intensity
I1(I1>255)=255;
I1(I1<0)=0;

randn('state', sum(100*clock));
d=randn(partAm,1)/2; %particle diameter distribution
d=dt+d*ddt;
d(d<0)=0;
rand('state', sum(100*clock));
x0=rand(partAm,1)*sizex;
y0=rand(partAm,1)*sizey;
rd = -8.0 ./ d.^2;
offsety=v;
offsetx=u;

xlimit1=floor(x0-d/2); %x min particle extent image1
xlimit2=ceil(x0+d/2); %x max particle extent image1
ylimit1=floor(y0-d/2); %y min particle extent image1
ylimit2=ceil(y0+d/2); %y max particle extent image1
xlimit2(xlimit2>sizex)=sizex;
xlimit1(xlimit1<1)=1;
ylimit2(ylimit2>sizey)=sizey;
ylimit1(ylimit1<1)=1;

%calculate particle extents for image2 (shifted image)
x0integer=round(x0);
x0integer(x0integer>sizex)=sizex;
x0integer(x0integer<1)=1;
y0integer=round(y0);
y0integer(y0integer>sizey)=sizey;
y0integer(y0integer<1)=1;

xlimit3=zeros(partAm,1);
xlimit4=xlimit3;
ylimit3=xlimit3;
ylimit4=xlimit3;
for n=1:partAm
    xlimit3(n,1)=floor(x0(n)-d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x min particle extent image2
    xlimit4(n,1)=ceil(x0(n)+d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x max particle extent image2
    ylimit3(n,1)=floor(y0(n)-d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y min particle extent image2
    ylimit4(n,1)=ceil(y0(n)+d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y max particle extent image2
end
xlimit3(xlimit3<1)=1;
xlimit4(xlimit4>sizex)=sizex;
ylimit3(ylimit3<1)=1;
ylimit4(ylimit4>sizey)=sizey;

set(handles.status_creation,'string','Placing particles...');drawnow;
for n=1:partAm
    r = rd(n);
    for j=xlimit1(n):xlimit2(n)
        rj = (j-x0(n))^2;
        for i=ylimit1(n):ylimit2(n)
            A(i,j)=A(i,j)+I0(n)*exp((rj+(i-y0(n))^2)*r);
        end
    end
    for j=xlimit3(n):xlimit4(n)
        for i=ylimit3(n):ylimit4(n)
            B(i,j)=B(i,j)+I1(n)*exp((-(j-x0(n)+offsetx(i,j))^2-(i-y0(n)+offsety(i,j))^2)*-rd(n)); %place particle with gaussian intensity profile
        end
    end
end

A(A>255)=255;
B(B>255)=255;

gen_image_1=imnoise(uint8(A),'gaussian',0,noise);
gen_image_2=imnoise(uint8(B),'gaussian',0,noise);

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
put('gen_image_1',gen_image_1);
put('gen_image_2',gen_image_2);



% --- Executes on button press in save_imgs.
function save_imgs_Callback(hObject, eventdata, handles)
gen_image_1=retr('gen_image_1');
gen_image_2=retr('gen_image_2');
if isempty(gen_image_1)==0
    [FileName,PathName] = uiputfile('*.tif','Save generated images as...',['PTVlab_gen.tif']);
    if isequal(FileName,0) | isequal(PathName,0)
    else
        Name=textscan(FileName,'%s%s','delimiter','.');
        FileName_1=[char(Name{1,1}) '_01.' char(Name{1,2})];
        FileName_2=[char(Name{1,1}) '_02.' char(Name{1,2})];
        if exist(fullfile(PathName,FileName_1),'file') >0 || exist(fullfile(PathName,FileName_2),'file') >0
            butt = questdlg(['Warning: File ' FileName_1 ' already exists.'],'File exists','Overwrite','Cancel','Overwrite')
            if strmatch(butt, 'Overwrite') == 1
                write_it=1;
            else
                write_it=0;
            end
        else
            write_it=1;
        end
        if write_it==1
            imwrite(gen_image_1,fullfile(PathName,FileName_1),'Compression','none')
            imwrite(gen_image_2,fullfile(PathName,FileName_2),'Compression','none')
        end
    end
end

% --- Executes on button press in dummy.
function dummy_Callback(hObject, eventdata, handles)
sliderdisp

function applyskipper_Callback(hObject, eventdata, handles)
filename=retr('filename');
filepath=retr('filepath');
handles=gethand;
skipper=str2num(get(handles.skipper, 'string'))+2;
filepathnew(1,1)=filepath(1,1);
filepathnew(2,1)=filepath(2,1);
filenamenew(1,1)=filename(1,1);
filenamenew(2,1)=filename(2,1);
countr=3;
for i=skipper+1:skipper:size(filepath,1)-2
    filepathnew(countr,1)=filepath(i,1);
    filepathnew(countr+1,1)=filepath(i+1,1);
    filenamenew(countr,1)=filename(i,1);
    filenamenew(countr+1,1)=filename(i+1,1);
    countr=countr+2;
end
%user alters source -> results have to be removed.
put('maskiererx' ,[]);
put('maskierery' ,[]);
put ('derived',[]);
put ('resultslist',[]);
filename=filenamenew;
filepath=filepathnew;
put ('filename',filename); %only for displaying
put ('filepath',filepath); %full path and filename for analyses
if size(filepath,1)>2
    sliderstepcount=size(filepath,1)/2;
    set(handles.fileselector, 'enable', 'on');
    set (handles.fileselector,'value',1, 'min', 1,'max',sliderstepcount,'sliderstep', [1/(sliderstepcount-1) 1/(sliderstepcount-1)*10]);
else
    sliderstepcount=1;
    set(handles.fileselector, 'enable', 'off');
    set (handles.fileselector,'value',1, 'min', 1,'max',2,'sliderstep', [0.5 0.5]);
end
set (handles.filenamebox, 'string', filename);
set(handles.skipper, 'enable', 'off');
set(handles.applyskipper, 'enable', 'off');
sliderdisp

function ptvlabhelp_Callback(hObject, eventdata, handles)
!PTVlab_tut.pdf

% --------------------------------------------------------------------
function aboutptv_Callback(hObject, eventdata, handles)
string={...
    'PTVlab - Time-Resolved Digital Particle Image Velocimetry Tool for MATLAB';...
    ['version: ' retr('PTVver')];...
    '';...
    'developed by Dipl. Biol. William Thielicke and Prof. Dr. Eize J. Stamhuis';...
    'published under the BSD licence.';...
    '';...
    '';...
    'programmed with MATLAB 7.1.0.246 (R14) Service Pack 3 (August 02, 2005)';...
    'first released March 09, 2010';...
    '';...
    
    'contact: antoine.patalano@gmail.com';...
    };
helpdlg(string,'About')

% --- Executes on button press in clear_everything.
function clear_everything_Callback(hObject, eventdata, handles)
put ('resultslist', []); %clears old results
put ('resultslistptv', []);
put ('derived', []);
handles=gethand;
set(handles.progress, 'String','Frame progress: N/A');
set(handles.overall, 'String','Total progress: N/A');
set(handles.totaltime, 'String','Time left: N/A');
set(handles.messagetext, 'String','');
sliderdisp

% --- Executes on button press in autoscale_vec.
function autoscale_vec_Callback(hObject, eventdata, handles)
handles=gethand;
if get(handles.autoscale_vec, 'value')==1
    set(handles.vectorscale,'enable', 'off');
else
    set(handles.vectorscale,'enable', 'on');
end

% --------------------------------------------------------------------
function save_session_Callback(hObject, eventdata, handles)
sessionpath=retr('sessionpath');
if isempty(sessionpath)
    sessionpath=retr('pathname');
end
[FileName,PathName] = uiputfile('*.mat','Save current session as...',fullfile(sessionpath,'PTVlab_session.mat'));
if isequal(FileName,0) | isequal(PathName,0)
else
    put('sessionpath',PathName );
    savesessionfuntion (PathName,FileName)
end

function savesessionfuntion (PathName,FileName)
hgui=getappdata(0,'hgui');
handles=gethand;
app=getappdata(hgui);
text(50,50,'Please wait, saving session...','color','y','fontsize',15, 'BackgroundColor', 'k','tag','savehint')
drawnow;
%Newer versions of Matlab do really funny things when the following vars are not empty...:
app.GUIDEOptions =[];
app.GUIOnScreen  =[];
app.Listeners  =[];
app.SavedVisible  =[];
app.ScribePloteditEnable  =[];
app.UsedByGUIData_m  =[];
app.lastValidTag =[];
iptPointerManager=[];
try
    iptPointerManager(gcf, 'disable')
end

save('-v6', fullfile(PathName,FileName), '-struct', 'app')
clear app hgui  iptPointerManager
% clahe_enable=get(handles.clahe_enable,'value');
% clahe_size=get(handles.clahe_size,'string');
% enable_highpass=get(handles.enable_highpass,'value');
% highp_size=get(handles.highp_size,'string');
% enable_clip=get(handles.enable_clip,'value');
% clip_thresh=get(handles.clip_thresh,'string');
% enable_intenscap=get(handles.enable_intenscap,'value');
enable_submean=get(handles.enable_submean,'value');
corrthre_val=get(handles.corrthre_val,'string');
sigma_size=get(handles.sigma_size,'string');
intthre_val=get(handles.intthre_val,'string');
gaussdetecmark=get(handles.gaussdetec, 'value');
dynadetecmark=get(handles.dynadetec, 'value');
intarea=get(handles.intarea,'string');
stepsize=get(handles.step,'string');
subpix=get(handles.subpix,'value');  %popup
ccmark=get(handles.cc, 'value');
rmmark=get(handles.rm, 'value');
hymark=get(handles.hy, 'value');
det_nummark=get(handles.det_num,'value');
det_areamark=get(handles.det_area,'value');
num_part=get(handles.num_part,'string');
area_size=get(handles.area_size,'string');
corrcc=get(handles.corrcc,'string');
percentcc=get(handles.percentcc,'string');
tn=get(handles.tn,'string');
tq=get(handles.tq,'string');
minneifrm=get(handles.minneifrm,'string');
tqfrm1=get(handles.tqfrm1,'string');
minprob=get(handles.minprob,'string');
stdev_check=get(handles.stdev_check,'value');
stdev_thresh=get(handles.stdev_thresh,'string');
loc_median=get(handles.loc_median,'value');
loc_med_thresh=get(handles.loc_med_thresh,'string');
epsilon=get(handles.epsilon,'string');
% interpol_missing=get(handles.interpol_missing,'value');
vectorscale=get(handles.vectorscale,'string');
colormap_choice=get(handles.colormap_choice,'value'); %popup
addfileinfo=get(handles.addfileinfo,'value');
add_header=get(handles.add_header,'value');
delimiter=get(handles.delimiter,'value');%popup
img_not_mask=get(handles.img_not_mask,'value');
autoscale_vec=get(handles.autoscale_vec,'value');
calxy=retr('calxy');
caluv=retr('caluv');
time=retr('time');
pointscali=retr('pointscali');
realdist_string=get(handles.realdist, 'String');
time_inp_string=get(handles.time_inp, 'String');
imginterpol=get(handles.popupmenu16, 'value');
dccmark=get(handles.dcc, 'value');
orthotrans=get(handles.orthotrans,'Value');
% fftmark=get(handles.fftmulti, 'value');
% pass2=get(handles.checkbox26, 'value');
% pass3=get(handles.checkbox27, 'value');
% pass4=get(handles.checkbox28, 'value');
% pass2val=get(handles.edit50, 'string');
% pass3val=get(handles.edit51, 'string');
% pass4val=get(handles.edit52, 'string');
% step2=get(handles.text126, 'string');
% step3=get(handles.text127, 'string');
% step4=get(handles.text128, 'string');
holdstream=get(handles.holdstream, 'value');
streamlamount=get(handles.streamlamount, 'string');
streamlcolor=get(handles.streamlcolor, 'value');


save('-v6', fullfile(PathName,FileName), '-append');
delete(findobj('tag','savehint'));
drawnow;

% --------------------------------------------------------------------
function load_session_Callback(hObject, eventdata, handles)
sessionpath=retr('sessionpath');
if isempty(sessionpath)
    sessionpath=retr('pathname');
end
[FileName,PathName, filterindex] = uigetfile({'*.mat','MATLAB Files (*.mat)'; '*.mat','mat'},'Load PTVlab session',fullfile(sessionpath, 'PTVlab_session.mat'));
if isequal(FileName,0) | isequal(PathName,0)
else
    clear iptPointerManager
    put('sessionpath',PathName );
    put('derived',[]);
    put('resultslist',[]);
    put('resultslistptv',[]);
    put('maskiererx',[]);
    put('maskierery',[]);
    put('roirect',[]);
    put('velrect',[]);
    put('filename',[]);
    put('filepath',[]);
    put('TrackID',[]);
    hgui=getappdata(0,'hgui');
    warning off all
    vars=load(fullfile(PathName,FileName),'yposition', 'FileName', 'PathName', 'add_header', 'addfileinfo', 'autoscale_vec', ...
        'caliimg', 'caluv', 'calxy', 'time','cancel',  'colormap_choice', 'delimiter', 'derived', 'displaywhat', 'distance', ...
        'enable_submean','epsilon', 'corrthre_val','sigma_size','gaussdetecmark','dynadetecmark','intthre_val','filename', ...
        'filepath', 'highp_size', 'homedir', 'img_not_mask','intarea', 'interpol_missing', 'loc_med_thresh', 'loc_median', ...
        'manualdeletion', 'maskiererx', 'maskierery', 'pathname','pointscali', 'resultslist', 'resultslistptv','roirect', ...
        'sequencer', 'sessionpath', 'stdev_check', 'stdev_thresh', 'stepsize', 'subpix','subtr_u', 'subtr_v', 'toggler', ...
        'vectorscale', 'velrect', 'wasdisabled', 'xposition','realdist_string','time_inp_string','streamlinesX','streamlinesY',...
        'manmarkersX','manmarkersY','imginterpol','pass2val','pass3val','pass4val','holdstream','streamlamount','streamlcolor',...
        'ismean','meanimg','ccmark','rmmark','hymark','det_nummark','det_areamark','num_part','area_size','corrcc','percentcc',...
        'tn','tq','minneifrm','tqfrm1','minprob','manualpoint','TrackID');
    names=fieldnames(vars);
    for i=1:size(names,1)
        setappdata(hgui,names{i},vars.(names{i}))
    end
    sliderrange
    handles=gethand;
    
    set(handles.clahe_enable,'value',retr('clahe_enable'));
    set(handles.clahe_size,'string',retr('clahe_size'));
    set(handles.enable_highpass,'value',retr('enable_highpass'));
    set(handles.highp_size,'string',retr('highp_size'));
    set(handles.enable_clip,'value',retr('enable_clip'));
    set(handles.clip_thresh,'string',retr('clip_thresh'));
    set(handles.enable_intenscap,'value',retr('enable_intenscap'));
    set(handles.enable_submean,'value',retr('enable_submean'));
    if vars.gaussdetecmark==1
        set(handles.corrthre_val,'string',retr('corrthre_val'));
        set(handles.sigma_size,'string',retr('sigma_size'));
        set(handles.intthre_val,'string',retr('intthre_val'));
    end
    if vars.dynadetecmark==1
        %         set(handles.corrthre_val,'string',retr('corrthre_val'));
        %         set(handles.sigma_size,'string',retr('sigma_size'));
        %         set(handles.intthre_val,'string',retr('intthre_val'));
    end
    set(handles.intarea,'string',retr('intarea'));
    set(handles.step,'string',retr('stepsize'));
    set(handles.cc,'value',vars.ccmark);
    set(handles.rm,'value',vars.rmmark);
    set(handles.hy,'value',vars.hymark);
    set(handles.det_num,'value',vars.det_nummark);
    set(handles.det_area,'value',vars.det_areamark);
    set(handles.num_part,'string',retr('num_part'));
    set(handles.area_size,'string',retr('area_size'));
    set(handles.corrcc,'string',retr('corrcc'));
    set(handles.percentcc,'string',retr('percentcc'));
    set(handles.tn,'string',retr('tn'));
    set(handles.tq,'string',retr('tq'));
    set(handles.minneifrm,'string',retr('minneifrm'));
    set(handles.tqfrm1,'string',retr('tqfrm1'));
    set(handles.minprob,'string',retr('minprob'));
    set(handles.subpix,'value',retr('subpix'));  %popup
    set(handles.stdev_check,'value',retr('stdev_check'));
    set(handles.stdev_thresh,'string',retr('stdev_thresh'));
    set(handles.loc_median,'value',retr('loc_median'));
    set(handles.loc_med_thresh,'string',retr('loc_med_thresh'));
    set(handles.epsilon,'string',retr('epsilon'));
    %     set(handles.interpol_missing,'value',retr('interpol_missing'));
    set(handles.vectorscale,'string',retr('vectorscale'));
    set(handles.colormap_choice,'value',retr('colormap_choice')); %popup
    set(handles.addfileinfo,'value',retr('addfileinfo'));
    set(handles.add_header,'value',retr('add_header'));
    set(handles.delimiter,'value',retr('delimiter'));%popup
    set(handles.img_not_mask,'value',retr('img_not_mask'));
    set(handles.autoscale_vec,'value',retr('autoscale_vec'));
    
    set(handles.popupmenu16, 'value',vars.imginterpol);
    %     set(handles.dcc, 'value',vars.dccmark);
    %     set(handles.fftmulti, 'value',vars.fftmark);
    %     if vars.fftmark==1
    %         set (handles.uipanel36,'visible','on')
    %     else
    %         set (handles.uipanel36,'visible','off')
    %     end
    %     set(handles.checkbox26, 'value',vars.pass2);
    %     set(handles.checkbox27, 'value',vars.pass3);
    %     set(handles.checkbox28, 'value',vars.pass4);
    %     set(handles.edit50, 'string',vars.pass2val);
    %     set(handles.edit51, 'string',vars.pass3val);
    %     set(handles.edit52, 'string',vars.pass4val);
    %     set(handles.text126, 'string',vars.step2);
    %     set(handles.text127, 'string',vars.step3);
    %     set(handles.text128, 'string',vars.step4);
    set(handles.holdstream, 'value',vars.holdstream);
    set(handles.streamlamount, 'string',vars.streamlamount);
    set(handles.streamlcolor, 'value',vars.streamlcolor);
    set(handles.streamlwidth, 'value',vars.streamlcolor);
%     set(handles.orthotrans, 'value',vars.orthotrans);
    try
        set(handles.realdist, 'String',vars.realdist_string);
        set(handles.time_inp, 'String',vars.time_inp_string);
        if isempty(vars.pointscali)==0
            caluv=retr('caluv');
            set(handles.calidisp, 'string', ['1 px/imagepair = ' num2str(round(caluv*1000)/1000) ' m/s'],  'backgroundcolor', [0.5 1 0.5]);
        end
    catch
        disp('.')
    end
    sliderdisp
end
% --- Executes on button press in saveavi.
function saveavi_Callback(hObject, eventdata, handles)
handles=gethand;
set(handles.fileselector, 'value',1)
filepath=retr('filepath');
startframe=str2num(get(handles.firstframe,'string'));
if startframe <1
    startframe=1;
elseif startframe>size(filepath,1)/2
    startframe=size(filepath,1)/2;
end
set(handles.firstframe,'string',int2str(startframe));
endframe=str2num(get(handles.lastframe,'string'));
if endframe <startframe
    endframe=startframe;
elseif endframe>size(filepath,1)/2
    endframe=size(filepath,1)/2;
end
set(handles.lastframe,'string',int2str(endframe));
p8wasvisible=retr('p8wasvisible');
if p8wasvisible==1
    switchui('multip08');
    sliderdisp
end
if get (handles.avifilesave, 'value')==1
    [filename, pathname] = uiputfile({ '*.avi','movie (*.avi)'}, 'Save movie as','PTVlab_out');
    if isequal(filename,0) || isequal(pathname,0)
        return
    end
    compr=get(handles.usecompr,'value');
    if compr==0
        compr='none';
    else
        compr='cinepak';
    end
    aviobj = avifile(fullfile(pathname,filename),'compression',compr,'quality', 100, 'fps', str2double(get(handles.fps_setting,'string')));
    for i=startframe:endframe
        set(handles.fileselector, 'value',i)
        sliderdisp
        hgca=gca;
        colo=get(gcf, 'colormap');
        axes_units = get(hgca,'Units');
        axes_pos = get(hgca,'Position');
        newFig=figure('visible', 'off');
        set(newFig,'visible', 'off');
        set(newFig,'Units',axes_units);
        set(newFig,'Position',[15 5 axes_pos(3)+30 axes_pos(4)+10]);
        axesObject2=copyobj(hgca,newFig);
        set(axesObject2,'Units',axes_units);
        set(axesObject2,'Position',[15 5 axes_pos(3) axes_pos(4)]);
        colormap(colo);
        F=getframe(axesObject2);
        close(newFig)
        aviobj = addframe(aviobj,F);
    end
    aviobj = close(aviobj);
elseif get (handles.jpgfilesave, 'value') ==1
    [filename, pathname] = uiputfile({ '*.jpg','image sequence (*.jpg)'}, 'Save images as','PTVlab_out');
    
    if isequal(filename,0) || isequal(pathname,0)
        return
    end
    reso=inputdlg(['Please enter scale factor' sprintf('\n') '(1 = render image at same size as currently displayed)'],'Specify resolution',1,{'1'});
    [reso status] = str2num(reso{1});  % Use curly bracket for subscript
    if ~status
        reso=1;
    end
    for i=startframe:endframe
        set(handles.fileselector, 'value',i)
        sliderdisp
        
        hgca=gca;
        colo=get(gcf, 'colormap');
        axes_units = get(hgca,'Units');
        axes_pos = get(hgca,'Position');
        aspect=axes_pos(3)/axes_pos(4);
        newFig=figure;
        set(newFig,'visible', 'off');
        set(newFig,'Units',axes_units);
        set(newFig,'Position',[15 5 axes_pos(3)+30 axes_pos(4)+10]);
        axesObject2=copyobj(hgca,newFig);
        set(axesObject2,'Units',axes_units);
        set(axesObject2,'Position',[15 5 axes_pos(3) axes_pos(4)]);
        colormap(colo);
        if get(handles.displ_colorbar,'value')==1
            colorbar ('South','FontWeight','bold');
        end
        Name=textscan(filename,'%s%s','delimiter','.');
        newfilename=[char(Name{1,1}) '_' sprintf('%03d',i) '.' char(Name{1,2})];
        exportfig(newFig,fullfile(pathname,newfilename),'height',3,'color','rgb','format','bmp','resolution',96*reso,'FontMode', 'scaled');
        close(newFig)
        autocrop(fullfile(pathname,newfilename),1);
    end
    
end

% --- Executes on selection change in extraction_choice.
function extraction_choice_Callback(hObject, eventdata, handles)
if get(hObject, 'value') ~= 9
    handles=gethand;
    if get(handles.draw_what, 'value')==3
        set(handles.draw_what, 'value', 1)
    end
end

% --- Executes on selection change in draw_what.
function draw_what_Callback(hObject, eventdata, handles)
if get(hObject, 'value') == 3
    handles=gethand;
    set (handles.extraction_choice, 'value', 9);
    set (handles.extraction_choice, 'enable', 'off');
else
    set (handles.extraction_choice, 'enable', 'on');
end

function check_comma(who)
boxcontent=get(who,'String');% returns contents of time_inp as text
s = regexprep(boxcontent, ',', '.');
set(who,'String',s);


%__________________________________________________________________________
%unused callbacks:
function slider1_Callback(hObject, eventdata, handles)
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%__________________________________________________________________________

% --- Executes on button press in vorticity_roi.
function vorticity_roi_Callback(hObject, eventdata, handles)
resultslist=retr('resultslist');
%currentframe=2*floor(get(handles.fileselector, 'value'))-1;
currentframe=floor(get(handles.fileselector, 'value'));

if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    if size(resultslist,1)>6 %filtered exists
        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
            u=resultslist{10,currentframe};
            v=resultslist{11,currentframe};
        else
            u=resultslist{7,currentframe};
            if size(u,1)>1
                v=resultslist{8,currentframe};
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
            end
        end
    else
        u=resultslist{3,currentframe};
        v=resultslist{4,currentframe};
    end
    caluv=retr('caluv');
    u=u*caluv-retr('subtr_u');
    v=v*caluv-retr('subtr_v');
    calxy=retr('calxy');
    derivative_calc(currentframe,2,1);
    derived=retr('derived');
    %currentimage=derived{1,(currentframe+1)/2};
    currentimage=derived{1,(currentframe)};
    delete(findobj('tag','vortarea'));
    h=figure;
    set (h,'DockControls', 'off', 'menubar', 'none', 'tag', 'vortarea')
    imagesc(currentimage);
    axis image
    hold on;
    quiver(u,v,'linewidth',str2double(get(handles.vecwidth,'string')))
    hold off;
    
    %draw ellipse
    for i=1:5
        [xellip(i),yellip(i),but] = ginput(1);
        if but~=1
            break
        end
        hold on;
        plot (xellip(i),yellip(i),'w*')
        hold off;
        if i==3
            line(xellip(2:3),yellip(2:3))
        end
        if i==5
            line(xellip(4:5),yellip(4:5))
        end
    end
    %click1=centre of vortical structure
    %click2=top of vortical structure
    %click3=bottom of vortical structure
    %click4=left of vortical structure
    %click5=right of vortical structure
    x0=(mean(xellip)+xellip(1))/2;
    y0=(mean(yellip)+yellip(1))/2;
    if xellip(2)<xellip(3)
        ang=acos((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)))-pi/2;
    else
        ang=asin((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)));
    end
    rb=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
    ra=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;
    text(xellip(1),yellip(1),int2str(ang/pi*180));
    ra=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
    rb=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;
    
    celllength=(x(1,2)-x(1,1))*calxy; %size of one cell
    cellarea=celllength^2; %area of one cell
    integralindex=0;
    for incr = -(ra+rb)/3 :0.5: (ra+rb)/2
        integralindex=integralindex+1;
        ra_new=ra+incr;
        if ra_new<0
            ra_new=0
        end
        if rb_new<0
            rb_new=0
        end
        rb_new=rb+incr;
        [outputx, outputy]=ELLIPSE(ra_new,rb_new,ang,x0,y0);
        BW = roipoly(u,outputx,outputy);
        integral=0;
        for i=1:size(u,1)
            for j=1:size(u,2)
                if BW(i,j)==1
                    integral=integral+cellarea*currentimage(i,j);
                end
            end
        end
        integralseries(integralindex)=integral;
    end
    h2=figure;
    set(h2, 'tag', 'vortarea');
    plot(integralseries)
end

% --- Executes on button press in draw_area.
function draw_area_Callback(hObject, eventdata, handles)
handles=gethand;
currentframe=floor(get(handles.fileselector, 'value'));
resultslist=retr('resultslist');
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    toolsavailable(0)
    areaoperation=get(handles.areatype, 'value');
    if areaoperation==1
        %area mean value
        sliderdisp
        filepath=retr('filepath');
        x=resultslist{1,currentframe};
        extractwhat=get(handles.area_para_select,'Value');
        derivative_calc(currentframe,extractwhat+1,0);
        derived=retr('derived');
        currentimage=imread(filepath{2*currentframe-1});
        sizeold=size(currentimage,1);
        sizenew=size(x,1);
        maptoget=derived{extractwhat,currentframe};
        maptoget=rescale_maps_nan(maptoget);
        [BW,ximask,yimask]=roipoly;
        delete(findobj('tag','areaint'));
        delete(findobj('tag', 'extractline'))
        delete(findobj('tag', 'extractpoint'))
        numcells=0;
        summe=0;
        for i=1:size(BW,1)
            for j=1:size(BW,2)
                if BW(i,j)==1
                    summe=summe+maptoget(i,j);
                    numcells=numcells+1;
                end
            end
        end
        average=summe/numcells;
        hold on;
        plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
        plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
        hold off;
        text(min(ximask),mean(yimask), ['area mean value = ' num2str(average)], 'BackgroundColor', 'w','tag','areaint');
        
    elseif areaoperation==2
        %area integral
        sliderdisp
        filepath=retr('filepath');
        x=resultslist{1,currentframe};
        extractwhat=get(handles.area_para_select,'Value');
        derivative_calc(currentframe,extractwhat+1,0);
        derived=retr('derived');
        maptoget=derived{extractwhat,currentframe};
        maptoget=rescale_maps_nan(maptoget);
        calxy=retr('calxy');
        currentimage=imread(filepath{2*currentframe-1});
        sizeold=size(currentimage,1);
        sizenew=size(x,1);
        [BW,ximask,yimask]=roipoly; %select in currently displayed image
        delete(findobj('tag','areaint'));
        delete(findobj('tag', 'extractline'))
        delete(findobj('tag', 'extractpoint'))
        celllength=1*calxy; %size of one pixel
        cellarea=celllength^2; %area of one cell
        integral=0;
        for i=1:size(BW,1)
            for j=1:size(BW,2)
                if BW(i,j)==1
                    integral=integral+cellarea*maptoget(i,j);
                end
            end
        end
        hold on;
        plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
        plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
        hold off;
        text(min(ximask),mean(yimask), ['area integral = ' num2str(integral)], 'BackgroundColor', 'w','tag','areaint');
    elseif areaoperation==3
        % area only
        sliderdisp
        filepath=retr('filepath');
        currentimage=imread(filepath{2*currentframe-1});
        x=resultslist{1,currentframe};
        sizeold=size(currentimage,1);
        sizenew=size(x,1);
        [BW,ximask,yimask]=roipoly;
        delete(findobj('tag','areaint'));
        delete(findobj('tag', 'extractline'))
        delete(findobj('tag', 'extractpoint'))
        calxy=retr('calxy');
        celllength=1*calxy;
        cellarea=celllength^2;
        summe=0;
        for i=1:size(BW,1)
            for j=1:size(BW,2)
                if BW(i,j)==1
                    summe=summe+cellarea;
                end
            end
        end
        hold on;
        plot(ximask,yimask,'LineWidth',3, 'Color', [0,0.95,0],'tag','areaint');
        plot(ximask,yimask,'LineWidth',1, 'Color', [0.95,0.5,0.01],'tag','areaint');
        hold off;
        text(min(ximask),mean(yimask), ['area = ' num2str(summe)], 'BackgroundColor', 'w','tag','areaint');
        
    elseif areaoperation==4
        %area series
        if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
            x=resultslist{1,currentframe};
            y=resultslist{2,currentframe};
            if size(resultslist,1)>6 %filtered exists
                if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
                    u=resultslist{10,currentframe};
                    v=resultslist{11,currentframe};
                else
                    u=resultslist{7,currentframe};
                    if size(u,1)>1
                        v=resultslist{8,currentframe};
                    else
                        u=resultslist{3,currentframe};
                        v=resultslist{4,currentframe};
                    end
                end
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
            end
            caluv=retr('caluv');
            u=u*caluv-retr('subtr_u');
            v=v*caluv-retr('subtr_v');
            calxy=retr('calxy');
            
            extractwhat=get(handles.area_para_select,'Value');
            derivative_calc(currentframe,extractwhat+1,0);
            derived=retr('derived');
            currentimage=derived{extractwhat,currentframe};
            
            
            currentimage=rescale_maps_nan(currentimage);
            
            sliderdisp
            
            delete(findobj('tag','vortarea'));
            
            %draw ellipse
            for i=1:5
                [xellip(i),yellip(i),but] = ginput(1);
                if but~=1
                    break
                end
                hold on;
                plot (xellip(i),yellip(i),'w*')
                hold off;
                if i==3
                    line(xellip(2:3),yellip(2:3))
                end
                if i==5
                    line(xellip(4:5),yellip(4:5))
                end
            end
            if size(xellip,2)==5
                %click1=centre of vortical structure
                %click2=top of vortical structure
                %click3=bottom of vortical structure
                %click4=left of vortical structure
                %click5=right of vortical structure
                x0=(mean(xellip)+xellip(1))/2;
                y0=(mean(yellip)+yellip(1))/2;
                if xellip(2)<xellip(3)
                    ang=acos((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)))-pi/2;
                else
                    ang=asin((yellip(2)-yellip(3))/(sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)));
                end
                rb=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
                ra=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;
                ra=sqrt((xellip(2)-xellip(3))^2+(yellip(2)-yellip(3))^2)/2;
                rb=sqrt((xellip(4)-xellip(5))^2+(yellip(4)-yellip(5))^2)/2;
                
                celllength=1*calxy;
                %celllength=(x(1,2)-x(1,1))*calxy; %size of one cell
                cellarea=celllength^2; %area of one cell
                integralindex=0;
                
                if get(handles.usethreshold,'value')==1
                    %sign=currentimage(round(yellip(1)),round(xellip(1)));
                    condition=get(handles.smallerlarger, 'value'); %1 is larger, 2 is smaller
                    thresholdareavalue=str2num(get(handles.thresholdarea, 'string'));
                    
                    if condition==1
                        currentimage(currentimage>thresholdareavalue)=nan;
                    else
                        currentimage(currentimage<thresholdareavalue)=nan;
                    end
                    %{
                    %redraw map to show excluded areas
                    [xhelper,yhelper]=meshgrid(1:size(u,2),1:size(u,1));
                    areaincluded=ones(size(u));
                    areaincluded(isnan(currentimage)==1)=0;
                    imagesc(currentimage);
                    axis image
                    hold on;
                    quiver(xhelper(areaincluded==1),yhelper(areaincluded==1),u(areaincluded==1),v(areaincluded==1),'k','linewidth',str2double(get(handles.vecwidth,'string')))
                    scatter(xhelper(areaincluded==0),yhelper(areaincluded==0),'rx')
                    hold off;
                    %}
                end
                increasefactor=str2num(get(handles.radiusincrease,'string'))/100;
                if ra<rb
                    minimumrad=ra;
                else
                    minimumrad=rb;
                end
                %for incr = -(minimumrad)/1.5 :0.5: (ra+rb)/2*increasefactor
                for incr = -(minimumrad)/1.5 :5: (ra+rb)/2*increasefactor
                    integralindex=integralindex+1;
                    [outputx, outputy]=ELLIPSE(ra+incr,rb+incr,ang,x0,y0,'w');
                    %BW = roipoly(u,outputx,outputy);
                    BW = roipoly(currentimage,outputx,outputy);
                    ra_all(integralindex)=ra+incr;
                    rb_all(integralindex)=rb+incr;
                    
                    integral=0;
                    %for i=1:size(u,1)
                    for i=1:size(currentimage,1)
                        %for j=1:size(u,2)
                        for j=1:size(currentimage,2)
                            if BW(i,j)==1
                                if isnan(currentimage(i,j))==0
                                    integral=integral+cellarea*currentimage(i,j);
                                end
                            end
                        end
                    end
                    integralseries(integralindex)=integral;
                end
                put('ra',ra_all);
                put('rb',rb_all)
                put('ang',ang)
                put('x0',x0)
                put('y0',y0)
                h2=figure;
                %plot(integralseries)
                set(h2, 'tag', 'vortarea');
                
                plot (1:size(integralseries,2), integralseries);
                hold on;
                scattergroup1=scatter(1:size(integralseries,2), integralseries, 80, 'ko');
                hold off;
                set(scattergroup1, 'ButtonDownFcn', @hitcircle2, 'hittestarea', 'off');
                title('Click the points of the graph to highlight it''s corresponding circle.')
                put('integralseries',integralseries);
                put ('hellipse',h2);
                screensize=get( 0, 'ScreenSize' );
                rect = [screensize(3)/2-300, screensize(4)/2-250, 600, 500];
                set(h2,'position', rect);
                
                extractwhat=get(handles.area_para_select,'Value');
                current=get(handles.area_para_select,'string');
                current=current{extractwhat};
                set(h2,'numbertitle','off','menubar','none','toolbar','figure','dockcontrols','off','name',[current ' area integral series, frame ' num2str(currentframe)]);
                set (gca, 'xgrid', 'on', 'ygrid', 'on', 'TickDir', 'in')
                xlabel('Ellipse series nr.');
                ylabel([current ' area integral']);
            end
        end
    elseif areaoperation==5
        %weighted centroid
        if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
            x=resultslist{1,currentframe};
            y=resultslist{2,currentframe};
            if size(resultslist,1)>6 %filtered exists
                if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
                    u=resultslist{10,currentframe};
                    v=resultslist{11,currentframe};
                else
                    u=resultslist{7,currentframe};
                    if size(u,1)>1
                        v=resultslist{8,currentframe};
                    else
                        u=resultslist{3,currentframe};
                        v=resultslist{4,currentframe};
                    end
                end
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
            end
            caluv=retr('caluv');
            u=u*caluv-retr('subtr_u');
            v=v*caluv-retr('subtr_v');
            calxy=retr('calxy');
            extractwhat=get(handles.area_para_select,'Value');
            derivative_calc(currentframe,extractwhat+1,0);
            derived=retr('derived');
            currentimage=derived{extractwhat,currentframe};
            delete(findobj('tag','vortarea'));
            
            imagesc(currentimage);
            axis image
            hold on;
            quiver(u,v,'k','linewidth',str2double(get(handles.vecwidth,'string')))
            hold off;
            
            avail_maps=get(handles.colormap_choice,'string');
            selected_index=get(handles.colormap_choice,'value');
            if selected_index == 4 %HochschuleBremen map
                load hsbmap.mat;
                colormap(hsb);
            elseif selected_index== 1 %rainbow
                load rainbow.mat;
                colormap (rainbow);
            else
                colormap(avail_maps{selected_index});
            end
            [BW,ximask,yimask]=roipoly;
            
            delete(findobj('tag', 'extractline'));
            line(ximask,yimask,'tag', 'extractline');
            [rows,cols] = size(currentimage);
            
            x = ones(rows,1)*[1:cols];
            y = [1:rows]'*ones(1,cols);
            area=0;
            meanx=0;
            meany=0;
            for i=1:size(currentimage,1)
                for j=1:size(currentimage,2)
                    if BW(i,j)==1
                        area=area+double(currentimage(i,j));%sum image intesity
                        meanx=meanx+x(i,j)*double(currentimage(i,j));%sum position*intensity
                        meany=meany+y(i,j)*double(currentimage(i,j));
                    end
                end
            end
            meanx=meanx/area;%*(sizeold/sizenew)
            meany=meany/area;%*(sizeold/sizenew)
            hold on; plot(meanx,meany,'w*','markersize',20,'tag', 'extractline');hold off;
        end
    elseif areaoperation==6
        %mean flow direction
        if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
            x=resultslist{1,currentframe};
            y=resultslist{2,currentframe};
            if size(resultslist,1)>6 %filtered exists
                if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
                    u=resultslist{10,currentframe};
                    v=resultslist{11,currentframe};
                else
                    u=resultslist{7,currentframe};
                    if size(u,1)>1
                        v=resultslist{8,currentframe};
                    else
                        u=resultslist{3,currentframe};
                        v=resultslist{4,currentframe};
                    end
                end
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
            end
            sliderdisp
            caluv=retr('caluv');
            u=u*caluv-retr('subtr_u');
            v=v*caluv-retr('subtr_v');
            calxy=retr('calxy');
            delete(findobj('tag','vortarea'));
            filepath=retr('filepath');
            x=resultslist{1,currentframe};
            [BW,ximask,yimask]=roipoly;
            delete(findobj('tag', 'extractline'));
            line(ximask,yimask,'tag', 'extractline');
            umean=0;
            vmean=0;
            uamount=0;
            u=rescale_maps_nan(u);
            v=rescale_maps_nan(v);
            for i=1:size(u,1)
                for j=1:size(u,2)
                    if BW(i,j)==1
                        umean=umean+u(i,j);
                        vmean=vmean+v(i,j);
                        uamount=uamount+1;
                    end
                end
            end
            umean=umean/uamount;
            vmean=vmean/uamount;
            veclength=(x(1,2)-x(1,1))*6;
            
            hold on;quiver(mean2(ximask), mean2(yimask), umean/sqrt(umean^2+vmean^2)*veclength,vmean/sqrt(umean^2+vmean^2)*veclength,'c','autoscale','off', 'autoscalefactor', 100, 'linewidth',2,'MaxHeadSize',3,'tag', 'extractline');hold off;
            %angle=atan(vmean/umean)*180/pi
        end
    end %areaoperation
end
toolsavailable(1)

function hitcircle2(src,eventdata)
posreal=get(gca,'CurrentPoint');
delete(findobj('tag','circstring'));
pos=round(posreal(1,1));
xposition=retr('xposition');
yposition=retr('yposition');
integralseries=retr('integralseries');
hgui=getappdata(0,'hgui');
h3plot=retr('hellipse');
figure(hgui);
delete(findobj('type', 'line', 'color', 'w')) %delete white ellipses
ra=retr('ra');
rb=retr('rb');
ang=retr('ang');
x0= retr('x0');
y0=retr('y0');

for m=1:size(ra,2)
    ELLIPSE(ra(1,m),rb(1,m),ang,x0,y0,'w');
end
ELLIPSE(ra(1,pos),rb(1,pos),ang,x0,y0,'b');
figure(h3plot);
marksize=linspace(80,80,size(ra,2))';
marksize(pos)=150;
set(gco, 'SizeData', marksize);
text(posreal(1,1)+0.25,posreal(2,2),['\leftarrow ' num2str(integralseries(pos))],'tag','circstring','BackgroundColor', [1 1 1], 'margin', 0.01, 'fontsize', 7, 'HitTest', 'off')

% --- Executes on selection change in areatype.
function areatype_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'value')==4
    set(handles.text93, 'visible', 'on')
    set(handles.smallerlarger, 'visible', 'on')
    set(handles.text94, 'visible', 'on')
    set(handles.radiusincrease, 'visible', 'on')
    set(handles.thresholdarea, 'visible', 'on')
    set(handles.usethreshold, 'visible', 'on')
    set(handles.text95, 'visible', 'on')
else
    set(handles.text93, 'visible', 'off')
    set(handles.smallerlarger, 'visible', 'off')
    set(handles.text94, 'visible', 'off')
    set(handles.radiusincrease, 'visible', 'off')
    set(handles.thresholdarea, 'visible', 'off')
    set(handles.usethreshold, 'visible', 'off')
    set(handles.text95, 'visible', 'off')
end


% --- Executes on selection change in flow_sim.
function flow_sim_Callback(hObject, eventdata, handles)
handles=gethand;
contents = get(hObject,'value');
set(handles.rankinepanel,'visible','off');
set(handles.shiftpanel,'visible','off');
set(handles.rotationpanel,'visible','off');
set(handles.oseenpanel,'visible','off');
if contents==1
    set(handles.rankinepanel,'visible','on');
elseif contents==2
    set(handles.oseenpanel,'visible','on');
elseif contents==3
    set(handles.shiftpanel,'visible','on');
elseif contents==4
    set(handles.rotationpanel,'visible','on');
end


% --- Executes on selection change in singledoublerankine.
function singledoublerankine_Callback(hObject, eventdata, handles)
handles=gethand;
contents = get(hObject,'value');
set(handles.rankx1,'visible','off');
set(handles.rankx2,'visible','off');
set(handles.ranky1,'visible','off');
set(handles.ranky2,'visible','off');
set(handles.text102,'visible','off');
set(handles.text103,'visible','off');
set(handles.text104,'visible','off');
if contents==1
    set(handles.rankx1,'visible','on');
    set(handles.ranky1,'visible','on');
elseif contents==2
    set(handles.rankx1,'visible','on');
    set(handles.ranky1,'visible','on');
    set(handles.rankx2,'visible','on');
    set(handles.ranky2,'visible','on');
    set(handles.text102,'visible','on');
    set(handles.text103,'visible','on');
    set(handles.text104,'visible','on');
end

% --- Executes on selection change in singledoubleoseen.
function singledoubleoseen_Callback(hObject, eventdata, handles)
handles=gethand;
contents = get(hObject,'value');
set(handles.oseenx1,'visible','off');
set(handles.oseenx2,'visible','off');
set(handles.oseeny1,'visible','off');
set(handles.oseeny2,'visible','off');
set(handles.text110,'visible','off');
set(handles.text111,'visible','off');
set(handles.text112,'visible','off');
if contents==1
    set(handles.oseenx1,'visible','on');
    set(handles.oseeny1,'visible','on');
elseif contents==2
    set(handles.oseenx1,'visible','on');
    set(handles.oseeny1,'visible','on');
    set(handles.oseenx2,'visible','on');
    set(handles.oseeny2,'visible','on');
    set(handles.text110,'visible','on');
    set(handles.text111,'visible','on');
    set(handles.text112,'visible','on');
end

% --- Executes on button press in meanmaker.
function meanmaker_Callback(hObject, eventdata, handles)
toolsavailable(0)
handles=gethand;
filepath=retr('filepath');
if size(filepath,1)>0
    %     sizeerror=0;
    resultslist=retr('resultslist');
    resultslistptv=retr('resultslistptv');
    resultslistRW=retr('resultslistRW');
    resultslistptvRW=retr('resultslistptvRW');
    
    set(handles.togglerealmesh,'value',1);
    if get(handles.orthotrans,'Value')==0
        for count=1:size(resultslistptv,2)
            %         if ismean(count,1)==0
            set(handles.meanmaker, 'string' , ['Total progress: ' int2str(count/size(resultslistptv,2)*100) '%'])
            BigU(:,:,count)=resultslist{3,count};
            BigV(:,:,count)=resultslist{4,count};
            drawnow
        end
        u=nanmean(BigU,3);%*(0.123*30);
        v=nanmean(BigV,3);%*(0.123*30);
        
        occ=u*nan;
        for i=1:size(u,1)
            for j=1:size(u,2)
                occ(i,j)=length(find(isnan(BigU(i,j,:))~=1)) ;
            end
        end
        maxocc=max(max(occ));
        
        x=resultslist{1,1};
        y=resultslist{2,1};
        
        resultslist{1,size(resultslistptv,2)+1}=x;
        resultslist{2,size(resultslistptv,2)+1}=y;
        resultslist{3,size(resultslistptv,2)+1}=u;
        resultslist{4,size(resultslistptv,2)+1}=v;
        put ('resultslist', resultslist);
        
    elseif get(handles.orthotrans,'Value')==1
        
        for count=1:size(resultslistptvRW,2)
            %         if ismean(count,1)==0
            set(handles.meanmaker, 'string' , ['Total progress: ' int2str(count/size(resultslistptv,2)*100) '%'])
            BigURW(:,:,count)=resultslistRW{3,count};
            BigVRW(:,:,count)=resultslistRW{4,count};
            drawnow
        end
        u=nanmean(BigURW,3);%*(0.123*30);
        v=nanmean(BigVRW,3);%*(0.123*30);
        
        occ=u*nan;
        for i=1:size(u,1)
            for j=1:size(u,2)
                occ(i,j)=length(find(isnan(BigURW(i,j,:))~=1)) ;
            end
        end
        maxocc=max(max(occ));
        
        x=resultslistRW{1,1};
        y=resultslistRW{2,1};
        
        resultslistRW{1,size(resultslistptvRW,2)+1}=x;
        resultslistRW{2,size(resultslistptvRW,2)+1}=y;
        resultslistRW{3,size(resultslistptvRW,2)+1}=u;
        resultslistRW{4,size(resultslistptvRW,2)+1}=v;
        put ('resultslistRW', resultslistRW);
    end
    



    
    filename=retr('filename');
    sessionpath=retr('PathName');
    %     if size(filename,1)==2*size(resultslistptv,2) %if the mean has never been calculated
    filepath{size(resultslistptv,2)*2+1,1}=[sessionpath 'MEANIMG' '.jpg'] ;
    filepath{size(resultslistptv,2)*2+2,1}=[sessionpath 'MEANIMG' '.jpg'] ;
    filename{size(resultslistptv,2)*2+1,1}=['A: MEAN VECTORS'];
    filename{size(resultslistptv,2)*2+2,1}=['B: MEAN VECTORS'];
    %     end
    
    
    put ('filepath', filepath);
    put ('filename', filename);
    %         put ('typevector', typevector);
    sliderrange
    try
        set (handles.fileselector,'value',get (handles.fileselector,'max'));
    catch
    end
    
    if get(handles.orthotrans,'Value')==0
    meanimg=retr('meanimg');
    
    if isempty(meanimg)==0
        sessionpath=retr('PathName');
        imwrite(uint8(meanimg) ,[sessionpath 'MEANIMG' '.jpg'])
    end
    end
    sliderdisp
    %     else %user tried to average analyses with different sizes
    %         errordlg('All analyses of one session have to be of the same size and have to be analyzed with identical PTV settings.','Averaging not possible...')
    %     end
    hocc=figure;
    pcolor(occ./maxocc)
    axis equal
    set(hocc,'numbertitle','off','toolbar','none','dockcontrols','off','name','Normalized data density');
    %set(hocc,'numbertitle','off','menubar','none','toolbar','none','dockcontrols','off','name','Normalized data density');
    title('Normalized data density in the whole session')
    set(gca, 'XTick', [], 'YTick', [],'YDir','reverse')
    hc=colorbar('location','eastoutside');
    set(handles.meanmaker, 'string' ,'Calculate mean of whole session')
    roirect=retr('roirect');
    if isempty(roirect)==1
    else
        text(0,3,['ROI: x=' int2str(roirect(1)) ' y=' int2str(roirect(2)) ' w=' int2str(roirect(3)) ' h=' int2str(roirect(4))],'color','r','fontsize',7, 'BackgroundColor', 'k', 'tag', 'roitext')
    end
    clear BigU BigV
    toolsavailable(1)
end

function part_am_Callback(hObject, eventdata, handles)
check_comma(hObject)
function part_size_Callback(hObject, eventdata, handles)
check_comma(hObject)
function part_var_Callback(hObject, eventdata, handles)
check_comma(hObject)
function part_noise_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseenx1_Callback(hObject, eventdata, handles)
check_comma(hObject)
function rank_core_Callback(hObject, eventdata, handles)
check_comma(hObject)
function rank_displ_Callback(hObject, eventdata, handles)
check_comma(hObject)
function rotationdislacement_Callback(hObject, eventdata, handles)
check_comma(hObject)
function realdist_Callback(hObject, eventdata, handles)
check_comma(hObject)
function time_inp_Callback(hObject, eventdata, handles)
check_comma(hObject)
function subtr_u_Callback(hObject, eventdata, handles)
check_comma(hObject)
function subtr_v_Callback(hObject, eventdata, handles)
check_comma(hObject)
function mapscale_min_Callback(hObject, eventdata, handles)
check_comma(hObject)
function mapscale_max_Callback(hObject, eventdata, handles)
check_comma(hObject)
function stdev_thresh_Callback(hObject, eventdata, handles)
check_comma(hObject)
function loc_med_thresh_Callback(hObject, eventdata, handles)
check_comma(hObject)
function epsilon_Callback(hObject, eventdata, handles)
check_comma(hObject)
function thresholdarea_Callback(hObject, eventdata, handles)
check_comma(hObject)
function shiftdisplacement_Callback(hObject, eventdata, handles)
check_comma(hObject)
function sheetthick_Callback(hObject, eventdata, handles)
check_comma(hObject)
function ranky1_Callback(hObject, eventdata, handles)
check_comma(hObject)
function rankx1_Callback(hObject, eventdata, handles)
check_comma(hObject)
function rankx2_Callback(hObject, eventdata, handles)
check_comma(hObject)
function ranky2_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseen_displ_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseenx2_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseeny1_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseeny2_Callback(hObject, eventdata, handles)
check_comma(hObject)
function oseen_time_Callback(hObject, eventdata, handles)
check_comma(hObject)
function part_z_Callback(hObject, eventdata, handles)
check_comma(hObject)
function vecwidth_Callback(hObject, eventdata, handles)
check_comma(hObject)

% --- Executes on button press in savejpgseq.
function savejpgseq_Callback(hObject, eventdata, handles)

% --- Executes on button press in avifilesave.
function avifilesave_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value')==1
    set (handles.jpgfilesave, 'value', 0);
    set(handles.usecompr,'enable','on');
    set(handles.fps_setting,'enable','on');
else
    set (handles.avifilesave, 'value', 1);
end

% --- Executes on button press in jpgfilesave.
function jpgfilesave_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value')==1
    set (handles.avifilesave, 'value', 0);
    set(handles.usecompr,'enable','off');
    set(handles.fps_setting,'enable','off');
    
else
    set (handles.jpgfilesave, 'value', 1);
end

% --- Executes on button press in drawstreamlines.
function drawstreamlines_Callback(hObject, eventdata, handles)
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    toolsavailable(0);
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    typevector=resultslist{5,currentframe};
    if size(resultslist,1)>6 %filtered exists
        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
            u=resultslist{10,currentframe};
            v=resultslist{11,currentframe};
            typevector=resultslist{9,currentframe}; %von smoothed
        else
            u=resultslist{7,currentframe};
            if size(u,1)>1
                v=resultslist{8,currentframe};
                typevector=resultslist{9,currentframe}; %von smoothed
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
                typevector=resultslist{5,currentframe};
            end
        end
    else
        u=resultslist{3,currentframe};
        v=resultslist{4,currentframe};
    end
    ismean=retr('ismean');
    if    numel(ismean)>0
        if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
            typevector=resultslist{5,currentframe};
        end
    end
    caluv=retr('caluv');
    u=u*caluv-retr('subtr_u');
    v=v*caluv-retr('subtr_v');
    u(typevector==0)=nan;
    v(typevector==0)=nan;
    calxy=retr('calxy');
    button=1;
    streamlinesX=retr('streamlinesX');
    streamlinesY=  retr('streamlinesY');
    if get(handles.holdstream,'value')==1
        if numel(streamlinesX)>0
            i=size(streamlinesX,2)+1;
            xposition=streamlinesX;
            yposition=streamlinesY;
        else
            i=1;
        end
    else
        i=1;
        put('streamlinesX',[]);
        put('streamlinesY',[]);
        xposition=[];
        yposition=[];
        delete(findobj('tag','streamline'));
    end
    while button == 1
        [rawx,rawy,button] = ginput(1);
        if button~=1
            break
        end
        xposition(i)=rawx;
        yposition(i)=rawy;
        h=streamline(stream2(x,y,u,v,xposition(i),yposition(i)));
        set (h,'tag','streamline');
        i=i+1;
    end
    delete(findobj('tag','streamline'));
    if exist('xposition')==1
        h=streamline(stream2(x,y,u,v,xposition,yposition));
        set (h,'tag','streamline');
        contents = get(handles.streamlcolor,'String');
        set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')})
        put('streamlinesX',xposition);
        put('streamlinesY',yposition);
    end
end
toolsavailable(1);

% --------------------------------------------------------------------
function Untitled_23_Callback(hObject, eventdata, handles)
switchui('multip18');

% --- Executes on button press in deletestreamlines.
function deletestreamlines_Callback(hObject, eventdata, handles)
put('streamlinesX',[]);
put('streamlinesY',[]);
delete(findobj('tag','streamline'));

% --- Executes on button press in streamrake.
function streamrake_Callback(hObject, eventdata, handles)
handles=gethand;
toggler=retr('toggler');
selected=2*floor(get(handles.fileselector, 'value'))-(1-toggler);
resultslist=retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    toolsavailable(0);
    x=resultslist{1,currentframe};
    y=resultslist{2,currentframe};
    typevector=resultslist{5,currentframe};
    if size(resultslist,1)>6 %filtered exists
        if size(resultslist,1)>10 && numel(resultslist{10,currentframe}) > 0 %smoothed exists
            u=resultslist{10,currentframe};
            v=resultslist{11,currentframe};
            typevector=resultslist{9,currentframe}; %von smoothed
        else
            u=resultslist{7,currentframe};
            if size(u,1)>1
                v=resultslist{8,currentframe};
                typevector=resultslist{9,currentframe}; %von smoothed
            else
                u=resultslist{3,currentframe};
                v=resultslist{4,currentframe};
                typevector=resultslist{5,currentframe};
            end
        end
    else
        u=resultslist{3,currentframe};
        v=resultslist{4,currentframe};
    end
    ismean=retr('ismean');
    if    numel(ismean)>0
        if ismean(currentframe)==1 %if current frame is a mean frame, typevector is stored at pos 5
            typevector=resultslist{5,currentframe};
        end
    end
    caluv=retr('caluv');
    u=u*caluv-retr('subtr_u');
    v=v*caluv-retr('subtr_v');
    u(typevector==0)=nan;
    v(typevector==0)=nan;
    calxy=retr('calxy');
    button=1;
    streamlinesX=retr('streamlinesX');
    streamlinesY=  retr('streamlinesY');
    if get(handles.holdstream,'value')==1
        if numel(streamlinesX)>0
            i=size(streamlinesX,2)+1;
            xposition=streamlinesX;
            yposition=streamlinesY;
        else
            i=1;
        end
    else
        i=1;
        put('streamlinesX',[]);
        put('streamlinesY',[]);
        xposition=[];
        yposition=[];
        delete(findobj('tag','streamline'));
    end
    [rawx,rawy,button] = ginput(1);
    hold on; scatter(rawx,rawy,'y*','tag','streammarker');hold off;
    [rawx(2),rawy(2),button] = ginput(1);
    delete(findobj('tag','streammarker'))
    rawx=linspace(rawx(1),rawx(2),str2num(get(handles.streamlamount,'string')));
    rawy=linspace(rawy(1),rawy(2),str2num(get(handles.streamlamount,'string')));
    
    xposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawx;
    yposition(i:i+str2num(get(handles.streamlamount,'string'))-1)=rawy;
    h=streamline(stream2(x,y,u,v,xposition(i),yposition(i)));
    set (h,'tag','streamline');
    i=i+1;
end
if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
    delete(findobj('tag','streamline'));
    h=streamline(stream2(x,y,u,v,xposition,yposition));
    contents = get(handles.streamlcolor,'String');
    set(h,'LineWidth',get(handles.streamlwidth,'value'),'Color', contents{get(handles.streamlcolor,'Value')});
    set (h,'tag','streamline');
    put('streamlinesX',xposition);
    put('streamlinesY',yposition);
end
toolsavailable(1);

% --- Executes on button press in applycolorwidth.
function applycolorwidth_Callback(hObject, eventdata, handles)
sliderdisp

% --- Executes on button press in putmarkers.
function putmarkers_Callback(hObject, eventdata, handles)
handles=gethand;
button=1;
manmarkersX=retr('manmarkersX');
manmarkersY=retr('manmarkersY');
if get(handles.holdmarkers,'value')==1
    
    if numel(manmarkersX)>0
        i=size(manmarkersX,2)+1;
        xposition=manmarkersX;
        yposition=manmarkersY;
    else
        i=1;
    end
else
    i=1;
    put('manmarkersX',[]);
    put('manmarkersY',[]);
    xposition=[];
    yposition=[];
    delete(findobj('tag','manualmarker'));
end
hold on;
while button == 1
    [rawx,rawy,button] = ginput(1);
    if button~=1
        break
    end
    xposition(i)=rawx;
    yposition(i)=rawy;
    plot(xposition(i),yposition(i), 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
    i=i+1;
end
delete(findobj('tag','manualmarker'));
plot(xposition,yposition, 'r*','Color', [0.55,0.75,0.9], 'tag', 'manualmarker');
put('manmarkersX',xposition);
put('manmarkersY',yposition);
hold off

% --- Executes on button press in delmarkers.
function delmarkers_Callback(hObject, eventdata, handles)
put('manmarkersX',[]);
put('manmarkersY',[]);
delete(findobj('tag','manualmarker'));

% --- Executes on button press in holdmarkers.
function holdmarkers_Callback(hObject, eventdata, handles)

% --- Executes on button press in displmarker.
function displmarker_Callback(hObject, eventdata, handles)
sliderdisp;

% --- Executes on button press in dcc.
function dcc_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value')==1
    set(handles.fftmulti,'value',0)
    set(handles.uipanel36,'visible','off')
    set(handles.text122,'visible','off')
else
    set(handles.dcc,'value',1)
end

% --- Executes on button press in fftmulti.
function fftmulti_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') ==1
    set(handles.dcc,'value',0)
    set(handles.uipanel36,'visible','on')
    set(handles.text122,'visible','on')
    
else
    set(handles.fftmulti,'value',1)
end





% --- Executes on button press in cc.
function cc_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 1
    set(handles.rm,'value',0)
    set(handles.hy,'value',0)
    set(handles.tn,'enable','off')
    set(handles.tq,'enable','off')
    set(handles.minneifrm,'enable','off')
    set(handles.tqfrm1,'enable','off')
    set(handles.minprob,'enable','off')
    set(handles.det_num,'enable','on')
    set(handles.det_area,'enable','on')
    if get(handles.det_num,'Value')==1
        set(handles.num_part,'enable','on')
        set(handles.area_size,'enable','off')
    elseif get(handles.det_area,'Value')==1
        set(handles.num_part,'enable','off')
        set(handles.area_size,'enable','on')
    end
    set(handles.corrcc,'enable','on')
    set(handles.percentcc,'enable','on')
    %set color of activated/inactivated text
    set(handles.uipanel48,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text159,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text160,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text163,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text165,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text164,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.uipanel47,'ForegroundColor',[0 0 0])
    set(handles.text148,'ForegroundColor',[0 0 0])
    set(handles.text149,'ForegroundColor',[0 0 0])
    set(handles.text161,'ForegroundColor',[0 0 0])
    set(handles.text162,'ForegroundColor',[0 0 0])
else
    set(handles.cc,'value',1)
end
if get(handles.det_area,'Value')==1
    dispareacc
end


function rm_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 1
    if get(handles.det_area,'Value')==1
        delete(findobj(gca,'Type','line','color','c'));
        delete(findobj(gca,'Type','text','color','g'));
    end
    set(handles.hy,'value',0)
    set(handles.cc,'value',0)
    set(handles.tn,'enable','on')
    set(handles.tq,'enable','on')
    set(handles.minneifrm,'enable','on')
    set(handles.tqfrm1,'enable','on')
    set(handles.minprob,'enable','on')
    set(handles.det_num,'enable','off')
    set(handles.det_area,'enable','off')
    set(handles.num_part,'enable','off')
    set(handles.area_size,'enable','off')
    set(handles.corrcc,'enable','off')
    set(handles.percentcc,'enable','off')
    %set color of activated/inactivated text
    set(handles.uipanel48,'ForegroundColor',[0 0 0])
    set(handles.text159,'ForegroundColor',[0 0 0])
    set(handles.text160,'ForegroundColor',[0 0 0])
    set(handles.text163,'ForegroundColor',[0 0 0])
    set(handles.text165,'ForegroundColor',[0 0 0])
    set(handles.text164,'ForegroundColor',[0 0 0])
    set(handles.uipanel47,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text148,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text149,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text161,'ForegroundColor',[0.502 0.502 0.502])
    set(handles.text162,'ForegroundColor',[0.502 0.502 0.502])
else
    set(handles.rm,'value',1)
end



% --- Executes on button press in hy.
function hy_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 1
    set(handles.rm,'value',0)
    set(handles.cc,'value',0)
    set(handles.tn,'enable','on')
    set(handles.tq,'enable','on')
    set(handles.minneifrm,'enable','on')
    set(handles.tqfrm1,'enable','on')
    set(handles.minprob,'enable','on')
    set(handles.det_num,'enable','on')
    set(handles.det_area,'enable','on')
    if get(handles.det_num,'Value')==1
        set(handles.num_part,'enable','on')
        set(handles.area_size,'enable','off')
    elseif get(handles.det_area,'Value')==1
        set(handles.num_part,'enable','off')
        set(handles.area_size,'enable','on')
    end
    set(handles.corrcc,'enable','on')
    set(handles.percentcc,'enable','on')
    %set color of activated/inactivated text
    set(handles.uipanel48,'ForegroundColor',[0 0 0])
    set(handles.text159,'ForegroundColor',[0 0 0])
    set(handles.text160,'ForegroundColor',[0 0 0])
    set(handles.text163,'ForegroundColor',[0 0 0])
    set(handles.text165,'ForegroundColor',[0 0 0])
    set(handles.text164,'ForegroundColor',[0 0 0])
    set(handles.uipanel47,'ForegroundColor',[0 0 0])
    set(handles.text148,'ForegroundColor',[0 0 0])
    set(handles.text149,'ForegroundColor',[0 0 0])
    set(handles.text161,'ForegroundColor',[0 0 0])
    set(handles.text162,'ForegroundColor',[0 0 0])
else
    set(handles.hy,'value',1)
end
if get(handles.det_area,'Value')==1
    dispareacc
end


% --- Executes on button press in det_num.
function det_num_Callback(hObject, eventdata, handles)
handles=gethand;
if get(handles.det_num,'Value')==1
    set(handles.num_part,'enable','on')
    set(handles.area_size,'enable','off')
elseif get(handles.det_area,'Value')==1
    set(handles.num_part,'enable','off')
    set(handles.area_size,'enable','on')
else
    set(handles.det_num,'value',1)
end
delete(findobj(gca,'Type','line','color','c'));
delete(findobj(gca,'Type','text','color','g'));






% --- Executes on button press in det_area.
function det_area_Callback(hObject, eventdata, handles)
handles=gethand;
if get(handles.det_area,'Value')==1
    set(handles.num_part,'enable','off')
    set(handles.area_size,'enable','on')
elseif get(handles.det_area,'Value')==1
    set(handles.num_part,'enable','on')
    set(handles.area_size,'enable','off')
else
    set(handles.det_area,'value',1)
end
dispareacc

% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 0
    set(handles.edit50,'enable','off')
    set(handles.edit51,'enable','off')
    set(handles.edit52,'enable','off')
    set(handles.checkbox27,'value',0)
    set(handles.checkbox28,'value',0)
else
    set(handles.edit50,'enable','on')
end

% --- Executes on button press in checkbox27.
function checkbox27_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 0
    set(handles.edit51,'enable','off')
    set(handles.edit52,'enable','off')
    set(handles.checkbox28,'value',0)
else
    set(handles.edit51,'enable','on')
end
if get(handles.checkbox26,'value')==0
    set(handles.checkbox27,'value',0)
    set(handles.edit51,'enable','off')
end

% --- Executes on button press in checkbox28.
function checkbox28_Callback(hObject, eventdata, handles)
handles=gethand;
if get(hObject,'Value') == 0
    set(handles.edit52,'enable','off')
else
    set(handles.edit52,'enable','on')
end
if get(handles.checkbox27,'value')==0
    set(handles.checkbox28,'value',0)
    set(handles.edit52,'enable','off')
end

function edit50_Callback(hObject, eventdata, handles)
handles=gethand;
step=str2double(get(hObject,'String'))
set (handles.text126, 'string', int2str(step/2));


function edit51_Callback(hObject, eventdata, handles)
handles=gethand;
step=str2double(get(hObject,'String'))
set (handles.text127, 'string', int2str(step/2));

function edit52_Callback(hObject, eventdata, handles)
handles=gethand;
step=str2double(get(hObject,'String'))
set (handles.text128, 'string', int2str(step/2));

% --------------------------------------------------------------------
 
 
 
 
 
 
 
function edit54_Callback(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit54 as text
%        str2double(get(hObject,'String')) returns contents of edit54 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit54_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on selection change in popupmenu17.
function popupmenu17_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu17 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu17
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in checkbox31.
function checkbox31_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox31
 
 
% --- Executes on button press in checkbox32.
function checkbox32_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox32
 
 
% --- Executes on button press in checkbox33.
function checkbox33_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox33
 
 
 
function edit55_Callback(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit55 as text
%        str2double(get(hObject,'String')) returns contents of edit55 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit55_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit56_Callback(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit57_Callback(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit57 as text
%        str2double(get(hObject,'String')) returns contents of edit57 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on selection change in popupmenu18.
function popupmenu18_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu18 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu18
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
 
 
 
 
% --- Executes on button press in radiobutton9.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of radiobutton9
 
 
 
function corrthre_val_Callback(hObject, eventdata, handles)
% hObject    handle to corrthre_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of corrthre_val as text
%        str2double(get(hObject,'String')) returns contents of corrthre_val as a double
 
 
% --- Executes during object creation, after setting all properties.
function corrthre_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrthre_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function sigma_size_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of sigma_size as text
%        str2double(get(hObject,'String')) returns contents of sigma_size as a double
 
 
% --- Executes during object creation, after setting all properties.
function sigma_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in enable_submean.
function enable_submean_Callback(hObject, eventdata, handles)
% hObject    handle to enable_submean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of enable_submean
 
 
 
 
 
function intthre_value_Callback(hObject, eventdata, handles)
% hObject    handle to intthre_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of intthre_value as text
%        str2double(get(hObject,'String')) returns contents of intthre_value as a double
 
 
% --- Executes during object creation, after setting all properties.
function intthre_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intthre_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
 
function intthre_val_Callback(hObject, eventdata, handles)
% hObject    handle to intthre_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of intthre_val as text
%        str2double(get(hObject,'String')) returns contents of intthre_val as a double
 
 
% --- Executes during object creation, after setting all properties.
function intthre_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intthre_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
 
function area_size_Callback(hObject, eventdata, handles)
dispareacc
% hObject    handle to area_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of area_size as text
%        str2double(get(hObject,'String')) returns contents of area_size as a double
 
 
% --- Executes during object creation, after setting all properties.
function area_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to area_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
 
 
% --- Executes on selection change in popupmenu19.
function popupmenu19_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu19 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu19
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on button press in checkbox36.
function checkbox36_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox36
 
 
% --- Executes on button press in checkbox37.
function checkbox37_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox37
 
 
% --- Executes on button press in checkbox38.
function checkbox38_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of checkbox38
 
 
 
function edit65_Callback(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit65 as text
%        str2double(get(hObject,'String')) returns contents of edit65 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit66_Callback(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function edit67_Callback(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of edit67 as text
%        str2double(get(hObject,'String')) returns contents of edit67 as a double
 
 
% --- Executes during object creation, after setting all properties.
function edit67_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
% --- Executes on selection change in popupmenu20.
function popupmenu20_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu20 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu20
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
function tq_Callback(hObject, eventdata, handles)
% hObject    handle to tq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of tq as text
%        str2double(get(hObject,'String')) returns contents of tq as a double
 
 
% --- Executes during object creation, after setting all properties.
function tq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function minneifrm_Callback(hObject, eventdata, handles)
% hObject    handle to minneifrm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of minneifrm as text
%        str2double(get(hObject,'String')) returns contents of minneifrm as a double
 
 
% --- Executes during object creation, after setting all properties.
function minneifrm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minneifrm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
function minprob_Callback(hObject, eventdata, handles)
% hObject    handle to minprob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of minprob as text
%        str2double(get(hObject,'String')) returns contents of minprob as a double
 
 
% --- Executes during object creation, after setting all properties.
function minprob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minprob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
% --- Executes during object creation, after setting all properties.
function corrcc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to corrcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
% --- Executes during object creation, after setting all properties.
function percentcc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to percentcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function tn_Callback(hObject, eventdata, handles)
% hObject    handle to tn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of tn as text
%        str2double(get(hObject,'String')) returns contents of tn as a double
 
 
% --- Executes during object creation, after setting all properties.
function tn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
function num_part_Callback(hObject, eventdata, handles)
% hObject    handle to num_part (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of num_part as text
%        str2double(get(hObject,'String')) returns contents of num_part as a double
 
 
% --- Executes during object creation, after setting all properties.
function num_part_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_part (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
function tqfrm1_Callback(hObject, eventdata, handles)
% hObject    handle to tqfrm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of tqfrm1 as text
%        str2double(get(hObject,'String')) returns contents of tqfrm1 as a double
 
 
% --- Executes during object creation, after setting all properties.
function tqfrm1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tqfrm1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
 
 
 
 
 
 
 
function corrcc_Callback(hObject, eventdata, handles)
% hObject    handle to corrcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of corrcc as text
%        str2double(get(hObject,'String')) returns contents of corrcc as a double
 
 
 
 
 
function percentcc_Callback(hObject, eventdata, handles)
% hObject    handle to percentcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of percentcc as text
%        str2double(get(hObject,'String')) returns contents of percentcc as a double

function multip19_CreateFcn(hObject, eventdata, handles)

 
function extraction_point_choice_CreateFcn(hObject, eventdata, handles)
 
 
function draw_point_CreateFcn(hObject, eventdata, handles)

 

% --- Executes on button press in dynadetec.
function dynadetec_Callback(hObject, eventdata, handles)

