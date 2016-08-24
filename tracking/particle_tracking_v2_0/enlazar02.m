function enlazar02(s_raiz,L,epsilon,salto)

% This code build the individual trajectory for each particle putting in
% order the file '*_fxyA.dat' made by "detect.m".
%
% Each trajectory will be save in a individual file ('s_raiz_t*.dat'). The
% first column of this file is the frame, the second is x_coordinate, the
% third is y_coordinate, and the rest column are the other parameters
% (area, ...) saved by "detect.m".
%
% The way to do that is to select a point in a frame and find which of the
% point in the next frame is the closest. This is recurrent and we obtain
% the complete trayectory of each particle. This process finish when there
% are not a point closer than epsilon in the next frame. In order to avoid
% noise, an algorithm is implemented: if there are two or more points which
% could be candidates to be the position of a particle in the same frame,
% this points are rejected (an alert will be displayed at the prompt:
% RUIDO), the trajectory is finished and started to build a newone. In this 
% way, it is posible that one particle will be represented in two or more
% trajectory-files, but those trayectories are not superimposed in time.

% The trajectories will be ploted on the first frame of the trajectory

% s_raiz: common part of the name from the files.
% Ej:'particle'

% L: minimum number of points in a trajectory. From all the trajectories
% that this code will build, only save those trajectories which have more
% than L points. It is advisable to elect L large. 

% epsilon: maximum distance (in pixels) between a point and the candidate
% to belong to the trajectory. It will be lightly bigger than the distance
% that the particles move between two consecutives frames. If you the
% adquisition rate is high, epsilon = 1, 0,5, ...

% salto: number of frames that one particle could be lost. In this frames
% the trajectory will linearly interpolate. I advise that salto=0 ALWAIS.

% WARNING: each time that this code runs delete all the trajectory-file
% saved at 'dir_2'

% As a result, you will obtain lots of files 's_raiz_t*.dat'. Each file
% is the trajectory of one particle and contain

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

dir_0= % folder where this program is. Ej: 'c:\experiments\a\software\'
dir_1= % folder where the data of the images analysis are.  Ej: 'c:\experiments\a\tracking'
dir_2= % folder where the data from trajectory will be saved Ej: 'c:\experiments\a\tracking'
dir_3= % folder where the images are Ej: 'c:\experiments\a\images'

radio=epsilon;  %  radious of the critical area in which could appear two or more candidates
n_number=3;     % number of digit in order to diferenciate the images.Ej: a_001.tif, a_002.tif , ... => n_number=3
formato='.tif'; % format of the image file
pausar=1;       % time (seconds) to pause after build a trajectory

param=load(strcat(dir_1,s_raiz,'_param.dat'));
n_rows=param(7);
n_columns=param(8);
coletilla='_fxyA.dat';%%%%% hay que cambiar que tipo de archivos va a borrar

% borra los archivos anteriores

delete(strcat(dir_2,s_raiz,'_t*.dat'));
delete(strcat(dir_2,s_raiz,'_Les.dat'));

set(0,'defaulttextinterpreter','none');

% carga de los datos de el reconocimiento de espots

dat=load(strcat(dir_1,s_raiz,coletilla));   

tam=length(dat);
frame=dat(:,1);
x=dat(:,2);
y=dat(:,3);
area=dat(:,4);
hecho=zeros(tam+1,1);     % columna que dice que punto ha sido seguido ya


% busca que indices corresponde a cada brame en el archivo de espots, el
% tamaño de cut debe ser igual al número de frames.

n=1;
m=1;
     
while (n<tam),    
    cut(m,:)=[frame(n) n 0];                % variable que almacena donde empieza y donde termina los datos de cada frame:
                                            % frame     indice_empieza      indice termina
    while((n<tam)&(frame(n)==frame(n+1))),
        n=n+1;
    end
    cut(m,3)=n;
    m=m+1;
    n=n+1;
end

% construye las trayectorias: elige un punto y busca dentro del archivo
% cual es el más próximo en el siguiente frame guardando el indice absoluto
% en la variable indices "ind".

n=1;        % contador absoluto
t=1;        % contador de trayectorias
save_ind=[]; % guardar el vector indices

while (n<tam)
    
    if(hecho(n)==0)

        i=1;        % contador de indices de trayectoria
        ind(i)=n;   % variable que contiene los indices
        hecho(n)=1;
        dat_save=[];    % variable que guardará los datos encontrados
        dat_falso=[];   % variable que guardará los datos que están interpolados
        p=[x(ind(i)) y(ind(i))];    %punto a seguir
        
        ind_f_ini=find(cut(:,3)>=n);     % busca el primer frame que todavía no ha sido analizado
        f_ini=cut(ind_f_ini(1),1)+1;    % pasa al siguiente frame

        terminar=0;             % cuando se pierde un punto durante mas de "saltos" teminar es 1 y cierra la trayectoria 

        for f=f_ini:length(cut),    % busca en los datos correspondientes a cada frame
            
            alerta=0;               % variable que alertará de la presencia de un spot más próximo que un radio
            puntos_alerta=[];       % puntos candidatos de ser ruido o el spot verdadero

            if(terminar<=salto)

                i=i+1;
                exito=0;                % exito es 1 si se encuentra en este frame un punto a una distacia menor que epsilon del punto que estabamos siguiendo
                d_min=2*epsilon;        % inicializa distancia mínima
                ind_ok_prev=tam+1;      % inicializa el incide bueno

                n_follow_ini=cut(f,2);
                n_follow_fin=cut(f,3);

                for m=n_follow_ini:n_follow_fin,    % busca en los datos en cada frame

                    if(hecho(m)==0)

                        pbis=[x(m) y(m)];
%                         d=pdist([p; pbis],'Euclidean');
                        d=sqrt((p(1)-pbis(1)).^2+(p(2)-pbis(2))^2);
                            
                        if(d < radio)
                            alerta=alerta+1;
                            puntos_alerta(alerta)=m;
                        end

                        if((d_min>d)&(d<=(epsilon*(terminar+1))))      % si la distancia es menor que la minima y menor que epsilon

                            hecho(ind_ok_prev)=0;       % vuelve a hábilitar el punto anterior
                            ind(i)=m;
                            ind_ok_prev=m;
                            hecho(m)=1;
                            d_min=d;
                            exito=1;

                        end

                    end

                end

                if( (exito==1) & (alerta == 1) )

                    p=[x(ind(i)) y(ind(i))];        % si no se ha perdido el punto el nuevo punto a seguir es el de menor distancia
                    
                else        % si se pierde el punto se pone 0 en la variable de indices de la trayectoria
                    
                    if ( alerta > 1 )
                        hecho(puntos_alerta)=1; % si hay posibilidad de ruido, todos estos puntos no se tendrán en cuenta para las siguiente trayectorias
                        terminar=terminar+1;
                        ind(i)=0;
                        disp('RUIDO')
                    else
                        hecho(ind_ok_prev)=0;
                        terminar=terminar+1;
                        ind(i)=0;
                    end
                end

                hasta=i; % numero de frames de la trayectoria

                while (ind(end)==0)    % se eliminan los puntos donde se ha perdido el espot
                    ind(end)=[];
                    hasta=hasta-1;
                    i=i-1;
                end


                % si salto es mayor que cero se hace una interpolación lineal
                % con los puntos que no se han encontrado

                if((i>salto)&(salto~=0)&(ind([i-salto:i-1])==zeros(1,salto))&(ind(i)~=0))

                    ind_fit=[(i-salto-1) (i)];
                    x_fit=x(ind_fit);
                    y_fit=y(ind_fit);

                    param_x=polyfit(ind_fit,x_fit',1);
                    param_y=polyfit(ind_fit,y_fit',1);

                    x_falso=polyval(param_x,[i-salto:i-1]);
                    y_falso=polyval(param_y,[i-salto:i-1]);
                    matriz_falso=[[(frame(ind(i-salto-1))+1):(frame(ind(i))-1)]' x_falso' y_falso' zeros(salto,1)];
                    dat_falso=[dat_falso;matriz_falso];

                end


            end

        end
        
        % gurdar las trayectorias si el número de puntos es mayor que "L"

        if(length(ind)<L)

            ind=[];

        else

            for o=1:hasta,

                % si el valor del indice encontrado es cero se sustituye por el
                % dato interpolado
                if(ind(o)==0),
                    dat_save(o,:)=dat_falso(1,:);
                    dat_falso(1,:)=[];
                else
                    dat_save(o,:)=dat(ind(o),:);
                end

            end

            save(strcat(dir_2,s_raiz,'_t',num2str(t),'.dat'),'dat_save','-ASCII');
            disp(strcat(s_raiz,'_t',num2str(t)));
            n_image=ind(1);
            save_ind=[save_ind ind];
            ind=[];
            t=t+1;

            % representa trayectorias
            t_p=dat_save(:,1);
            x_p=dat_save(:,2);
            y_p=dat_save(:,3);
            A_p=dat_save(:,4);

            rojos=[];
            rojos=find(A_p==0);

            subplot(2,2,1)
            plot(t_p,n_columns-y_p,'.');
            if ~isempty(rojos)
                hold on
                plot(t_p(rojos),n_columns-y_p(rojos),'o');
                hold off
            end
            xlabel('frame');
            ylabel('pixel');
            title(strcat('trajectory ',num2str(t-1),'. y coordinate'));
            subplot(2,2,3)
            plot(t_p,n_rows-x_p,'.');
            if ~isempty(rojos)
                hold on
                plot(t_p(rojos),n_rows-x_p(rojos),'o');
                hold off
            end
            xlabel('frame');
            ylabel('pixel');title(strcat('trajectory ',num2str(t-1),'. x coordinate'));
            
                     % represento el punto sobre la imagen

            n_zeros=n_number-length(num2str(frame(n_image)));    
            cero='0';
            while (length(cero)<n_zeros),
                cero=strcat(cero,'0');
            end
            s=strcat(s_raiz,'_',cero,num2str(frame(n_image)),formato);

            A=imread(strcat(dir_3,s));
            subplot(1,2,2)
            imshow(A);
            hold on;
            plot(x(n_image),y(n_image),'or','MarkerSize',5)
            title(s);
            hold off;
            drawnow
            
            pause(pausar);
        end

    end

    n=n+1;
    
end


% guarda el archivo con los parámetros utilizados.

param=[L,epsilon,salto];
save_ind=sort(save_ind');
save(strcat(dir_2,s_raiz,'_Les.dat'),'param','-ASCII');


% representar trayectorias todas juntas

files=dir(strcat(dir_2,s_raiz,'_t*.dat'));
nfiles=length(files);
colores=hsv(nfiles);
clear files;

close
figure
hold on

for n=1:nfiles,
    dat=[];
    name=strcat(s_raiz,'_t',num2str(n),'.dat');
    dat=load(strcat(dir_2,name));
    frame=dat(:,1);
    y=n_rows-dat(:,3);
    plot(frame,y,'Color',colores(n,:));
end

xlabel('frame');
ylabel('pixel');
title(strcat('Trajectories'));
drawnow;

cd(dir_0)

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