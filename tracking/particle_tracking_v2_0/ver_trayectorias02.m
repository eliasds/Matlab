function ver_trayectorias02(s_raiz,ind)

% This program only shows the trajectories build by "enlazar.m"

% s_raiz: common part of the name from the files.
% Ej:'KSR_10126_19_29_25C06c1'

% ind: number of the frame which the trajectorie will be plotted on.

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


close all;

dir_0= % folder where this program is. Ej: 'c:\experiments\a\software\'
dir_1= % folder where the data of the images analysis are.  Ej: 'c:\experiments\a\tracking'
dir_2= % folder where the data from trajectory will be saved Ej: 'c:\experiments\a\tracking'
dir_3= % folder where the images are Ej: 'c:\experiments\a\images'

%% parámetros 

n_number=3;     % number of digit in order to diferenciate the images.Ej: a_001.tif, a_002.tif , ... => n_number=3
formato='.tif'; % format of the image file

param=load(strcat(dir_1,s_raiz,'_param.dat'));
n_rows=param(7);
n_columns=param(8);


set(0,'defaulttextinterpreter','none');


files=dir(strcat(dir_2,s_raiz,'_t*.dat'));
nfiles=length(files);
colores=hsv(nfiles);
clear files;

% trayectoria por trayectoria

for n=1:nfiles,
    
    dat=[];
    name=strcat(s_raiz,'_t',num2str(n),'.dat');
    dat=load(strcat(dir_2,name));
    frame=dat(:,1);
    x=dat(:,2);
    y=n_rows-dat(:,3);
    
    n_zeros=n_number-length(num2str(frame(ind)));    
    cero='0';
    while (length(cero)<n_zeros),
        cero=strcat(cero,'0');
    end
    s=strcat(s_raiz,'_',cero,num2str(frame(ind)),formato);

    A=imread(strcat(dir_3,s));                            % se lee el archivo de imagen
    subplot(1,2,2)
    imshow(A);
    hold on;
    plot(x(ind),n_columns-y(ind),'or','MarkerSize',5)
    title(s);
    hold off;
    
    subplot(2,2,1)
    plot(frame,y,'.');
    hold on
    plot(frame(ind),y(ind),'+r','Markersize',5);
    hold off
    xlabel('frame');
    ylabel('pixel');
    title(strcat('trajectory ',num2str(n),'. y coordinate'));
    subplot(2,2,3)
    plot(frame,x,'.');
    hold on
    plot(frame(ind),x(ind),'+r','Markersize',5);
    hold off
    xlabel('frame');
    ylabel('pixel');title(strcat('trajectory ',num2str(n),'. x coordinate'));
    pause;
end

% todas las trayectorias

close
figure
hold on

for n=1:nfiles,
    dat=[];
    name=strcat(s_raiz,'_t',num2str(n),'.dat');
    dat=load(strcat(dir_2,name));
    frame=dat(:,1);
    x=dat(:,2);
    y=n_rows-dat(:,3);
%     subplot(1,2,2);
    hold on;
    plot(x,y,'Color',colores(n,:));
    axis square;
    xlabel('pixel');
    ylabel('pixel');
    hold off;
%     subplot(2,2,1);
%     hold on;
%     plot(frame,y,'Color',colores(n,:));
%     axis square;
%     xlabel('frame');
%     ylabel('pixel');
%     hold off;
%     subplot(2,2,3);
%     hold on;
%     plot(frame,x,'Color',colores(n,:));
%     axis square;
%     xlabel('frame');
%     ylabel('pixel');
%     hold off;
end
% subplot(1,2,2);
hold on
title(strcat('Trajectories:  ',s_raiz));

cd (dir_0)

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