
function uimakevideo(PathName,FileName)

% Version: 1.0, 6 August 2012
% Author:  Antoine Patalano

%uipickfiles: GUI program to select file(s) and/or directories.
%
% Syntax:
%   files = uimakevideo('PathName','FileName')

% FileName='M4H06168.avi';
% PathName='C:\Documents and Settings\Administrador\Mis documentos\Laboratorio_LH\Proyectos_LH\4_Planta Bajo Grande\23 de Abril de 2012\M4H06168\delta1\';
% try


%      VideoReader([PathName FileName]);
warning off
obj=[];
 this_frame=[];
info=aviinfo([PathName FileName]);

    fps=info.FramesPerSecond;
nframe=info.NumFrames;
Width=info.Width;
Height=info.Height;

%  disp('Please download and install the necessary video CODECS: <a href="http://download.cnet.com/AVI-Codec-Pack-Pro/3000-2140_4-10509745.html">AVI-Codec-Pack-Pro</a> and <a href="http://www.4shared.com/file/8io3dYaG/m3jpegv3.html">m3jpegv3</a> ')
% disp('<a href="matlab: doc plot; ">Click here for plot documentation</a>')
% Create figure.
gray = get(0,'DefaultUIControlBackgroundColor');
fig = figure('Position',[0 0 200 230],...
    'Color',gray,...
    'WindowStyle','modal',...
    'Resize','off',...
    'NumberTitle','off',...
    'Name','Movie to frames',...
    'IntegerHandle','off',...
    'CreateFcn',{@movegui,'center'}); %#ok<NOPRT>

% This is a ... s movie at .. fps
uicontrol('Position',[10 198 200 21],...
    'Style','text',...
    'String',['This is a ' num2str(round(nframe*100/fps)/100) ' s movie at ' num2str(round(fps)) ' fps'], ...
    'HorizontalAlignment','left')

uicontrol('Position',[10 160 53 15],...
    'Style','text',...
    'String','Step:', ...
    'HorizontalAlignment','left')

% Step
step_value=uicontrol('Position',[40 160 20 20],...
    'Style','edit',...
    'String',num2str(round(fps)/2), ...
    'HorizontalAlignment','center',...
    'Callback', @StepCallback);

uicontrol('Position',[60 160 53 15],...
    'Style','text',...
    'String','frame(s)', ...
    'HorizontalAlignment','left')

 Slider = uicontrol('Style','Slider',...
     'Position',[110,160,70,20],...
    'CallBack', @SliderCallBack, ...
    'Value',round(fps)/2,...
    'Min',1,'Max',round(fps), ...
    'SliderStep', [1/round(fps-1) 0]);



%Range
uicontrol('Position',[10 122 60 15],...
    'Style','text',...
    'String','Range: from', ...
    'HorizontalAlignment','left')

Time_min=uicontrol('Position',[72 122 27 20],...
    'Style','edit',...
    'String','0', ...
    'HorizontalAlignment','center',...
    'Callback', @TimeMinCallback);

uicontrol('Position',[100 122 20 15],...
    'Style','text',...
    'String','s to', ...
    'HorizontalAlignment','left')
Time_max=uicontrol('Position',[125 122 27 20],...
    'Style','edit',...
    'String',num2str(round(info.NumFrames/info.FramesPerSecond)), ...
    'HorizontalAlignment','center',...
    'Callback', @TimeMaxCallback);

uicontrol('Position',[153 122 20 15],...
    'Style','text',...
    'String','s', ...
    'HorizontalAlignment','left')

%Select the resolution
uicontrol('Position',[10 84 103 24],...
    'Style','text',...
    'String','Image Resolution:', ...
    'HorizontalAlignment','left')

 List = {[num2str(Width) 'x' num2str(Height)], ...
     [num2str(round(Width*2/3)) 'x' num2str(round(Height*2/3))],...
     [num2str(round(Width/2)) 'x' num2str(round(Height/2))]};
     
PopupMenu=uicontrol('Position',[100 87 80 24],...
    'Style','popupmenu',...
    'String',List,...
    'CallBack', @PopupMenuCallBack);

%check box Invert
invert_value=uicontrol('Position',[10 46 103 24],...
    'Style','checkbox',...
    'String','Invert Colors', ...
    'HorizontalAlignment','left', ...
    'Value', 0.0);

%Make Frame
BottonMkf=uicontrol('Position',[54 11 110 28],...
    'Style','pushbutton',...
    'String','Make Frames', ...
    'HorizontalAlignment','left',...
    'Callback',@Mkf);

% catch
%     disp('Please download and install the necessary video CODECS: <a href="http://download.cnet.com/AVI-Codec-Pack-Pro/3000-2140_4-10509745.html">AVI-Codec-Pack-Pro</a> and <a href="http://www.4shared.com/file/8io3dYaG/m3jpegv3.html">m3jpegv3</a> ')
% end
    function StepCallback(varargin)
        exnum=get(Slider,'Value');
        num = str2num(get(step_value,'String'));
        if length(num) == 1 & num <=round(fps) & num >=1 %#ok<AND2>
            set(Slider,'Value',num);
        else
            msgbox(['The value should be a number in the range [0,' num2str(round(fps)) ']'],'Error','error','modal');
            set(step_value,'String',num2str(exnum));     
        end
    end

    function TimeMinCallback(varargin)        
        num = str2num(get(Time_min,'String'));
        if length(num) == 1 & num <str2num(get(Time_max,'String')) & num >=0 %#ok<AND2>
%             set(Slider,'Value',num);
        else
            msgbox('The Time range selected is wrong','Error','error','modal');
            set(Time_min,'String',num2str(num));     
        end
    end
    function TimeMaxCallback(varargin)        
        num = str2num(get(Time_max,'String'));
        if length(num) == 1 & num >str2num(get(Time_min,'String')) & num >=0 & num <=round(info.NumFrames/info.FramesPerSecond)%#ok<AND2>
%             set(Slider,'Value',num);
        else
            msgbox('The Time range selected is wrong','Error','error','modal');
            set(Time_max,'String',num2str(num));     
        end
    end




  function SliderCallBack(varargin)    
    num = get(Slider, 'Value');
    set(step_value, 'String', num2str(num));    
  end

  function PopupMenuCallBack(varargin)
  
    List = get(PopupMenu,'String');
    Val = get(PopupMenu,'Value');
%     msgbox(List{Val},'Selecting:','modal')

  end

    function Mkf(varargin)        
        StepValue=str2double(get(step_value,'String')); 
        Val = get(PopupMenu,'Value');
        if Val==1
            factor=1;
        end
        if Val==2
            factor=2/3;
        end
        if Val==3
            factor=1/2;
        end
        
        
        Tmin=str2num(get(Time_min,'String'));
        Tmax=str2num(get(Time_max,'String'));
        TminVec=round((Tmin*info.FramesPerSecond))+1;
        TmaxVec=round((Tmax*info.FramesPerSecond))+1;
        
        %         for i= str2num(get(Time_min,'String'))*info.FramesPerSecond
        try      
            if exist('mmreader.m')==2
                obj = mmreader([PathName FileName]);
            end
            
        for i=TminVec:StepValue:TmaxVec
            try
            frame=aviread([PathName FileName],i);
            frame=frame.cdata;
            catch
                frame = read(obj, i);
            end
            frame=rgb2gray(frame);
            if factor~=1
                frame=imresize(frame,factor);
            end
            %invert colors
            if get(invert_value,'Value')==1
                frame=double(frame);                
                frame=uint8(abs(frame-255));
            end
            
            rootnameout='IMG_';
            index=num2str(i,['%0',num2str(length(num2str(round(nframe)))),'i']);
            extnameout='.jpg';       
            filename=[PathName char(strcat(rootnameout,char(index),extnameout))];                
            imwrite(frame,filename,'jpg');
            set(BottonMkf, 'string' , ['Total progress: ' int2str((i-TminVec+1)/(((TmaxVec-TminVec)+1))*100) '%'],...
                'ForegroundColor', [0.502 0.502 0.502])
            drawnow
        end
        catch
            disp(['Please download and install the necessary video CODECS: '  info.VideoCompression ' or encode in divx: '])       
        end
        close
    end
end
            
                
               

% function step_value(varargin)

