%% Plot 3D Particle information
% Version 1.0
tic
clear all
undock
vidon=1; %Set to 1 to save video
framerate=30;
load('constants.mat');
%[m,n]=size(Ein);
radix2 = 2048;
xmax = 2048; % max pixels in x propagation
ymax = 2048; % max pixels in y propagation
zmax = 0.0120; % max distance in z propagation
xscale = 1000*ps/mag; %recontructed pixel distance in mm
yscale = 1000*ps/mag; %recontructed pixel distance in mm
zscale = 1000; %recontructed distance in mm
rect = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
lastframe = 'numfiles';
lastframe = '100';
m=0;
xyzfile='analysis-20141128/Basler_acA2040-25gm__21407047__20141125_173229048-th5E-03_dernum5_day73593174841.mat';
% load('background.mat');
dirname='';
filename='Basler_acA2040-25gm__21407047__20141125_173229048_';
ext = 'tiff';

varnam=who('-file',xyzfile);
beadxyz=load(xyzfile,varnam{1});
beadxyz=beadxyz.(varnam{1});

fignum=1;
handle=figure(fignum); set(handle, 'Position', [700 200 512 422])
%clear beadxyz;beadxyz=E1;

filename = strcat(dirname,filename);
filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);
for L = 1:numfiles
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

mov(eval(lastframe)).cdata=[];
mov(eval(lastframe)).colormap=[];
M=0;
for L=1:eval(lastframe)
%     L=L+5;
%     figure(fignum)
    plot3(xscale*beadxyz(L+M).time(:,4),zscale*(10E-3-zmax+beadxyz(L+M).time(:,6)),yscale*(ymax-beadxyz(L+M).time(:,5)),'b.');
    axis([0,ceil(xscale*xmax),0,ceil(zscale*zmax),0,ceil(yscale*ymax)]);
%     view(15,15) % small perspective in z
%     view(0,0) %flat
%     view(-38+3*L-3,30+3*L-3)
%     view(-38+L/10,30)
%     view(-34,18)
    view(-150,20)
    xlabel('(mm)')
    zlabel('(mm)')
    ylabel('Through Focus (mm)')
    title(['Frame#:',num2str(L),'   (time in AU)']);
    grid on
    box on
%     axis image
    hold on
    for M=0:m
    plot3(xscale*beadxyz(L+M).time(:,1),zscale*(10E-3-zmax+beadxyz(L+M).time(:,5)),yscale*(ymax-beadxyz(L+M).time(:,2)),'b.');
    end
    drawnow
    hold off
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