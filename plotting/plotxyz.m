%% Plot 3D Particle information
% Version 2.0

%%idea for finding real max and min z values:
% Accurate to within 20um with first dataset. Giving cuvette depth of
% 5.02mm instead of 5mm
%
% for L=1:512
% Mmin(L)=min(xyzLoc(1, L).time(:,3));
% Mmax(L)=max(xyzLoc(1, L).time(:,3));
% end
% [M,F]=mode(Mmin);
% [M,F]=mode(Mmax);

%%
tic
clear all
undock
vidonflag = false; %Set to true to save video
plotvortflag = false; %Set to true if you want to plot approx location of vorticella
insertbackgroundflag = true;
drawlinesflag = false;
framerate=40;
avgnumframes=0;
%[m,n]=size(Ein);
% radix2 = 2048;
filename='Basler_acA2040-25gm__21407047';
ext = 'tiff';
% xyzfile=['analysis-20150413/Basler_acA2040-25gm-th8E-02_dernum3-15_day73606793391.mat'];
% dirname='D:\shuldman\20150325\10mmCuvette2mmOutside_MaxParticlesTrial2\';
xyzfile=['analysis-20150414/Basler_acA2040-25gm-th8E-02_dernum3-8_day73606849900.mat'];
dirname='D:\shuldman\20150325\10mmCuvetteHalfwayIn_MaxParticlesTrial2\';
load([dirname,'constants.mat']);
load([dirname,'background.mat']);
% xmax = 1024; % max pixels in x propagation
% ymax = 1024; % max pixels in y propagation
xmax = rect(3); % max pixels in x propagation
ymax = rect(4); % max pixels in y propagation
zmax = abs(z2-z1); % max distance in z propagation
xscale = 1000*ps/mag; %recontructed pixel distance in mm
yscale = 1000*ps/mag; %recontructed pixel distance in mm
zscale = 1000; %recontructed distance in mm
% rect = [vortloc(1)-radix2/2,vortloc(2)-radix2,radix2-1,radix2-1]; %Cropping
% rect = [Xceil,Yceil,xmax-1,ymax-1]; %Cropping
rect2 = [512 512 1023 1023];
% lastframe = 'numfiles';
lastframe = '100';
% lastframe = 'length(xyzLoc)';
varnam=who('-file',xyzfile);
xyzLoc=load(xyzfile,varnam{1});
xyzLoc=xyzLoc.(varnam{1});
fignum=1001;
handle=figure(fignum); set(handle, 'Position', [100 100 768 512])
% view(-150,20)
% view(-34,18)
% view(15,15) % small perspective in z
view(0,0) %flat overlaying hologram
% view(180,0) %reverse flat
% view(0,90) %Projected along x-axis to view changes in z
[az,el] = view;
plotstr = 'figure(fignum); scatter3(xscale*xyzLoc(L+M).time(:,1),zscale*(-z2+xyzLoc(L+M).time(:,3)),yscale*(ymax-xyzLoc(L+M).time(:,2)),30,''filled'');';
tmp = z1;
z1 = max(tmp,z2);
z2 = min(tmp,z2);
clear tmp;

filename = strcat(dirname,filename);
filesort = dir([filename,'*.',ext]);
numfiles = numel(filesort);
for L = 1:numfiles-avgnumframes
    [filesort(L).pathstr, filesort(L).firstname, filesort(L).ext] = ...
        fileparts([filesort(L).name]);
    %filesort(i).matname=strcat(filesort(i).matname,'.mat');
end

mov(eval(lastframe)-avgnumframes).cdata = [];
mov(eval(lastframe)-avgnumframes).colormap = [];
L=1;
M=0;
eval(plotstr)
for L=1:eval(lastframe)-avgnumframes
    hold off
    clf('reset')
    view([az,el])
%     figure(fignum)
%     for M=1:avgnumframes
%         groupz(:,M)=xyzLoc(L+M-1).time(:,3);
%     end
%     meanz=mean(groupz,2);
%     modez=mode(groupz,2);
%     medianz=median(groupz,2);
%     plot3(xscale*xyzLoc(L).time(:,1),zscale*(-z1+meanz),yscale*(xyzLoc(L).time(:,2)),'b.');
%     plot3(xscale*xyzLoc(L+M).time(:,1),zscale*(-z1+xyzLoc(L+M).time(:,3)),yscale*(xyzLoc(L+M).time(:,2)),'b.');
    %% Insert Hologram image as backdrop
    %
    if insertbackgroundflag == true;
        Holo = sqrt(imcrop(double(imread([filesort(L).name])) ./ background,rect));
        % title(['3D Particle Detection']);
        colormap gray
        figure(fignum); hold off;
        surface('XData',[0 xscale*xmax; 0 xscale*xmax],'YData',[zscale*zmax zscale*zmax; zscale*zmax zscale*zmax],'ZData',[0 0; yscale*ymax yscale*ymax],'CData',(flipud(Holo)),'FaceColor','texturemap','EdgeColor','none');
        hold on
    end
    
    %% average none or several frames together (poorly)
    for M=0:avgnumframes
        if M>0
            hold on
        end
        eval(plotstr);
    end
    
    %% Draw big Vorticella
    if plotvortflag == true
        plot_3d(xscale*vortloc(1),zscale*(-z1+vortloc(3)),(yscale*(ymax-vortloc(2))),.1*[1,1,1],[1,0,0]);
    end

    %% Draw lines back to the Hologram plane.
    if drawlinesflag == true
        for N=1:10;
            scatter3([xscale*xyzLoc(L).time(N,1),xscale*xyzLoc(L).time(N,1)],[0,zscale*(-z1+xyzLoc(L).time(N,3))],[(yscale*(ymax-xyzLoc(L).time(N,2))),(yscale*(ymax-xyzLoc(L).time(N,2)))],'b-');
        end
    end
    
    axis([0,ceil(2*xscale*xmax)/2,0,ceil(zscale*zmax),0,ceil(2*yscale*ymax)/2]);

    hold off
    xlabel('(mm)')
    zlabel('(mm)')
    ylabel('Through Focus (mm)')
    title(['Frame#:',num2str(L),'   (time in AU)']);
    grid on
    grid minor
    box on
    view([az,el])
    drawnow
%     axis image
    if vidonflag==true
%        t = colorbar;
%        set(get(t,'ylabel'),'string','Z Depth(m)','fontsize',16)
        mov(:,L) = getframe(fignum) ;
    end
end
hold off

if vidonflag==true
    filename=xyzfile;
    writerObj = VideoWriter([filename(1:end),'_',num2str(uint8(rand*100))],'MPEG-4');
    writerObj.FrameRate = framerate;
    open(writerObj);
    writeVideo(writerObj,mov);
    close(writerObj);
end

toc