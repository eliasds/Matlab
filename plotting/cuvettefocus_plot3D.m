%% Plot 3D Particle information
% Version 1.0

%%idea for finding real max and min z values:
% Accurate to within 20um with first dataset. Giving cuvette depth of
% 5.02mm instead of 5mm
%
% for L=1:512
% Mmin(L)=min(beadxyz(1, L).time(:,3));
% Mmax(L)=max(beadxyz(1, L).time(:,3));
% end
% [M,F]=mode(Mmin);
% [M,F]=mode(Mmax);

%%
tic
clear all
undock
vidon=1; %Set to 1 to save video
framerate=40;
load('constants.mat');
avgnumframes=0;
%[m,n]=size(Ein);
% radix2 = 2048;
xmax = Xfloor-Xceil; % max pixels in x propagation
ymax = Yfloor-Yceil; % max pixels in y propagation
zmax = z2-z1; % max distance in z propagation
zmax = 5E-3;
xscale = 1000*ps/mag; %recontructed pixel distance in mm
yscale = 1000*ps/mag; %recontructed pixel distance in mm
zscale = 1000; %recontructed distance in mm
% rect = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
rect = [Xceil,Yceil,xmax-1,ymax-1]; %Cropping
lastframe = 'numfiles';
lastframe = '10';
filename='Basler_acA2040-25gm__21407047__20150121_162008320';
ext = 'tiff';
xyzfile=['analysis-20150128/Basler_acA2040-25gm__21407047__20150121_162008320-th9E-03_dernum4_day73599343778.mat'];
load('background.mat');
dirname='';

varnam=who('-file',xyzfile);
beadxyz=load(xyzfile,varnam{1});
beadxyz=beadxyz.(varnam{1});

fignum=1000;
handle=figure(fignum); set(handle, 'Position', [700 200 512 422])
%clear beadxyz;beadxyz=E1;

filename = strcat(dirname,filename);
filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);
for L = 1:numfiles-avgnumframes
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

mov(eval(lastframe)-avgnumframes).cdata=[];
mov(eval(lastframe)-avgnumframes).colormap=[];
M=0;
plot3(xscale*beadxyz(L+M).time(:,1),zscale*(-z1+beadxyz(L+M).time(:,3)),yscale*(ymax-beadxyz(L+M).time(:,2)),'b.');
view(-150,20)
for L=1:eval(lastframe)-avgnumframes
    [az,el] = view;
%     L=L+5;
%     figure(fignum)
%     for M=1:avgnumframes
%         groupz(:,M)=beadxyz(L+M-1).time(:,3);
%     end
%     meanz=mean(groupz,2);
%     modez=mode(groupz,2);
%     medianz=median(groupz,2);
%     plot3(xscale*beadxyz(L).time(:,1),zscale*(-z1+meanz),yscale*(beadxyz(L).time(:,2)),'b.');
%     plot3(xscale*beadxyz(L+M).time(:,1),zscale*(-z1+beadxyz(L+M).time(:,3)),yscale*(beadxyz(L+M).time(:,2)),'b.');
%     hold on
    %% average none or several frames together (poorly)
    for M=0:avgnumframes
        if M>0
            hold on
        end
        plot3(xscale*beadxyz(L+M).time(:,1),zscale*(-z1+beadxyz(L+M).time(:,3)),yscale*(ymax-beadxyz(L+M).time(:,2)),'b.');
    end
    
    %% Draw big Vorticella
    plot_3d(xscale*vortloc(1),zscale*(-z1+vortloc(3)),(yscale*(ymax-vortloc(2))),.1*[1,1,1],[1,0,0]);

    %% Draw lines back to the Hologram plane.
%     for M=1:10;
%         plot3([xscale*beadxyz(L).time(M,1),xscale*beadxyz(L).time(M,1)],[0,zscale*(-z1+beadxyz(L).time(M,3))],[(yscale*(ymax-beadxyz(L).time(M,2))),(yscale*(ymax-beadxyz(L).time(M,2)))],'b-');
%     end
    
    axis([0,ceil(2*xscale*xmax)/2,0,ceil(zscale*zmax),0,ceil(2*yscale*ymax)/2]);
%     view(15,15) % small perspective in z
%     view(0,0) %flat
%     view(-38+3*L-3,30+3*L-3)
%     view(-38+L/10,30)
%     view(-34,18)

    %% Insert Hologram image as backdrop
    %
    Holo = sqrt(imcrop(double(imread([filesort(L).name])) ./ background,rect));
    % title(['3D Particle Detection']);
    colormap gray
    surface('XData',[0 xscale*xmax; 0 xscale*xmax],'YData',[0 0; 0 0],...
        'ZData',[0 0; yscale*ymax yscale*ymax],'CData',flipud(Holo),...
        'FaceColor','texturemap','EdgeColor','none');
    %

    hold off
    xlabel('(mm)')
    zlabel('(mm)')
    ylabel('Through Focus (mm)')
    title(['Frame#:',num2str(L),'   (time in AU)']);
    grid on
    box on
    view([az,el])
    drawnow
%     axis image
    if vidon==1
%        t = colorbar;
%        set(get(t,'ylabel'),'string','Z Depth(m)','fontsize',16)
        mov(:,L) = getframe(fignum) ;
    end
end
hold off

if vidon==1
    filename=xyzfile;
    writerObj = VideoWriter([filename(1:end),'_',num2str(uint8(rand*100))],'MPEG-4');
    writerObj.FrameRate = framerate;
    open(writerObj);
    writeVideo(writerObj,mov);
    close(writerObj);
end

toc