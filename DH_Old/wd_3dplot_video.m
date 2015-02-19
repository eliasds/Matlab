%% Plot 3D Particle information and save to movie
% Version 1.0

clear mov;

set(0,'DefaultFigureWindowStyle','normal') 
tic
filename='whiskers';
framerate=15;
fignum=20;
numfiles=length(whiskers);
numfiles=10

zmin=30E-3; %don't plot below this z depth for better colormap and video
zmax=45E-3;

for L=1:numfiles
    figure(fignum)
    set(fignum,'Position',[10,150,1010,550],'color','w');
    wd_3dplot(whiskers(L).time,zmin,zmax)
    title(['Time:',num2str(L)]);
    grid on
    box on
    drawnow
    %hold on
    %pause(0.1)
    %hold off
    mov(:,L) = getframe(fignum) ;
    clf
end
%hold off

writerObj = VideoWriter(strcat(filename,'3D_',num2str(uint8(rand*100))),'MPEG-4');
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,mov);
close(writerObj);



toc
    
