function detect02(s_raiz,umbral_1,umbral_2,area_1,area_2,caja,elipse)

% Detection of the bright spot in a image using morphological criteria.
% The criteria for the detection of the spots are: gray scale, area and 
% shape (close to circular shape). It calculates the centroids of spot using
% a weight average with the gray scale.

% As a result, you will obtain a file 's_raiz_fxyA.dat' containing frame,
% x-coordinate, y-coordinate of the centroid, and other parameters in 
% columns (this file will be procesing by 'enlazar.m'), and other file 
% 's_raiz_param.dat' that contains the parameter used in the processing.

% s_raiz: common part of the name from the files. Ej:
% 'KSR_10126_19_29_25C06c1'

% umbral_1: minimum gray level
% umbral_2: maximum gray level
% if umbral_1=0 and umbral_2=0, this criterium not to be apply

% area_1: minimum area
% area_2: maximum area
% if area_1=0 and area_2=0, this criterium not to be apply

% caja: quotient between high and wide of the spot
% if caja=0, this criterium not to be apply

% elipse: eccetricity of the spot
% if elipse=1, this criterium not to be apply

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                   %
%   Developed by:   Martin Pastor                                   %
%                                                                   %
%                   Granular Media Laboratory                       %
%                   Univ. de Navarra - Dept. Applied Physics        %
%                   C\Irunlarrea, s/n "Edificio los Castaños"       %
%                   31.080 - Pamplona (Navarra) Spain               %
%                   Tel: (+ 34) 948 425 600 - Ext: 6562 Ext: 6412   %
%                   Fax: (+ 34) 948 425 649                         %
%                                                                   %
%                   e-mail: jpgutierrez@alumni.unav.es              %
%                   web: http://fisica.unav.es/granular/            %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
set(0,'defaulttextinterpreter','none');

dir_0= % folder where this program is. Ej: 'c:\experiments\a\software\'
dir_1= % folder where the images are.  Ej: 'c:\experiments\a\images\'
dir_2= % folder where the data will be saved Ej: 'c:\experiments\a\tracking'


formato='.tif';         % format of the image file
n_number=3;             % number of digit in order to diferenciate the images.Ej: a_001.tif, a_002.tif , ... => n_number=3
pausar=1;               % time (seconds) to pause afte analyzate "refresco" images
refresco=20;            % number of images between pauses. Every pause, the code show the frame

    
    %% detection of the spots

files=dir(strcat(dir_1,s_raiz,'*',formato));
nfiles=length(files);   % number of images in the folder

image_cali=imread(strcat(dir_1,files(1).name));
tam_image=size(image_cali);
n_rows=tam_image(1);             % number of rows and colums of the image
n_columns=tam_image(2);

%% si la division en imagenes esta hecho con otro programa empieza en cero
cero='0';
while (length(cero)<n_number),
    cero=strcat(cero,'0');
end    
restar=dir(strcat(dir_1,s_raiz,'_',cero,formato));
if(isempty(restar)),
    restar=0;
else
    restar=1;
end

clear files image_cali tam_image;

data=[];
data_g=[];
data_std=[];

disp(s_raiz);

for n=1:nfiles,
    
    n_zeros=n_number-length(num2str(n-restar));    
    cero='0';
    while (length(cero)<n_zeros),
        cero=strcat(cero,'0');
    end
    s=strcat(s_raiz,'_',cero,num2str(n-restar),formato);
    
    A=imread(strcat(dir_1,s));A=A(:,:,1);                            % reading the image file
      
    
    I=zeros(size(A));              % binarization of the images between two threshold
    cambiar=find(([A]>=umbral_1)&([A]<=umbral_2));
    I(cambiar)=1;
    I=imfill(I,'holes');        % filling holes
    
    I=imclearborder(I);     % clearing borders
    
    [labeled,numObjects] = bwlabel(I);    % searching clusters: labeled and propierties
    balldata = regionprops(labeled,'Area');
    
    % area
    
    if ((area_1~=0) | (area_2~=0)) 
        
        selected = find(([balldata.Area]>=area_1)&([balldata.Area]<=area_2));
        I = ismember(labeled,selected);
        
    end

    [labeled,numObjects] = bwlabel(I);    % searching clusters: labeled and propierties
    balldata = regionprops(labeled,'Eccentricity');
        

    % eccentricity

    if (elipse~=1)

        selected = find([balldata.Eccentricity]<=elipse); 
        I = ismember(labeled,selected);

    end

    [labeled,numObjects] = bwlabel(I);   % searching clusters: labeled and propierties
    balldata = regionprops(labeled,'Area','BoundingBox','Eccentricity');
      
    
    if (~isempty(balldata))     

        %centroids
        
        for k=1:numObjects,     % calculating the centroid using the gray scale
            
            clear grays row column;
            [row,column]=find(labeled==k);              % coodinates of the selected area
            grays=double(A((column-1)*n_rows+row));     % gray scale of the selected area
            
            x_gray(k)=column'*grays/sum(grays);
            y_gray(k)=row'*grays/sum(grays);
        end
        
        clear grays row column;

        % area

        area=[balldata.Area];

        % shape

        BB= [balldata.BoundingBox];
        if (~isempty(BB))
            x_BB=BB(1:4:end-3);
            y_BB=BB(2:4:end-2);
            ancho_BB=BB(3:4:end-1);
            alto_BB=BB(4:4:end);
        end

        % eccentricity

        excentricidad=[balldata.Eccentricity];

        data_act=[n*ones(length(balldata),1) x_gray' y_gray' area' x_BB' y_BB' ancho_BB' alto_BB' excentricidad'];
        clear x_gray y_gray;

        % criterio de rectangulo

        if (caja~=0)  % si se elige criterio de area se ejecuta este paso

            selected = find(((ancho_BB./alto_BB)>=caja)|((alto_BB./ancho_BB)>=caja));   % eleccion de cluster de acuerdo al area
            if (~isempty(selected))            % el formato de datos es x e y en una misma columna
                data_act(selected,:)=[];
            end

        end
        
    else
        
        data_act=[];
        
    end % si hay puntos
    
    if (~isempty(data_act))
        data=[data;data_act]; %guardar datos
    end
    
       
    if (mod(n,refresco)==0)
        disp(n);
        imshow(A);
        hold on;
        if(~isempty(data_act))
            plot(data_act(:,2),data_act(:,3),'or','MarkerSize',2)
        end
        hold off;
        title(strcat('Image: ',s));
        pause(pausar);
    end
        
    clear x y area x_BB y_BB ancho_BB alto_BB ex;
    clear data_act;
    
end

% this parameters will be used for other codes
param=[umbral_1 umbral_2 area_1 area_2 caja elipse n_rows n_columns];

save(strcat(dir_2,s_raiz,'_param.dat'),'param','-ASCII');
save(strcat(dir_2,s_raiz,'_fxyA.dat'),'data','-ASCII');
   
cd(dir_0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                   %
%   Developed by:   Martin Pastor                                   %
%                                                                   %
%                   Granular Media Laboratory                       %
%                   Univ. de Navarra - Dept. Applied Physics        %
%                   C\Irunlarrea, s/n "Edificio los Castaños"       %
%                   31.080 - Pamplona (Navarra) Spain               %
%                   Tel: (+ 34) 948 425 600 - Ext: 6562 Ext: 6412   %
%                   Fax: (+ 34) 948 425 649                         %
%                                                                   %
%                   e-mail: jpgutierrez@alumni.unav.es              %
%                   web: http://fisica.unav.es/granular/            %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%