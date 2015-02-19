set(0,'DefaultFigureWindowStyle','normal') 
tic
eps=6.5E-3/4; % mm
%fignum=19;
a=0.0E-3;
b=12E-3;
c=size(beadxyz,2)/1;
c=20
d=round(c/1.1);
d=0;
matsizex=2560;
matsizey=2160;
%figure(fignum)
fignum = figure('Position',[10,50,1200,400],'color','w');
%clear beadxyz;beadxyz=E1;

%% Convert data from pixel number to mm
beadxyzmm=beadxyz;
a=0.0;
b=12;
matsizex=matsizex*eps;
matsizey=matsizey*eps;


for m=1:size(beadxyz,2)
    beadxyzmm(m).time(:,1:2)=eps*beadxyz(m).time(:,1:2);
    beadxyzmm(m).time(:,3)=1E3*beadxyz(m).time(:,3);
end

%%
for m=1:c
    subplot(1,2,1)
    plot3(beadxyzmm(m).time(:,1),beadxyzmm(m).time(:,3),-1*beadxyzmm(m).time(:,2),'b.');
    axis([0,matsizex,a,b,-1*matsizey,0]);
    xlabel('X (mm)')
    ylabel('Z (mm)')
    zlabel('Y (mm)')
    grid on
    box on
    view(15,15); set(get(gca,'YLabel'),'Rotation',40.0) % small perspective in z
    %view(0,180); % set(get(gca,'YLabel'),'Rotation',0.0) %flat
    title(['Time:',num2str(m)]);
    hold on
    [x,y,z] = sphere(200);
    plot3(0.13*x+(1240*6.5E-3)/4,2*y+4.5,0.1*z-(2040*6.5E-3)/4,'ro')  % sphere centered at (8.58,4.2,13.75)
    hold off

    subplot(1,2,2)
    plot3(beadxyzmm(m).time(:,1),beadxyzmm(m).time(:,3),beadxyzmm(m).time(:,2),'b.');
    axis([0,matsizex,a,b,0,matsizey]);
    xlabel('X (mm)')
    ylabel('Z (mm)')
    zlabel('Y (mm)')
    grid on
    box on
    %view(15,15); set(get(gca,'YLabel'),'Rotation',30.0) % small perspective in z
    view(0,180); % set(get(gca,'YLabel'),'Rotation',0.0) %flat
    title(['Time:',num2str(m)]);
    hold on
    [x,y,z] = sphere(200);
    plot3(0.13*x+(1240*6.5E-3)/4,2*y+4.5,0.1*z+(2040*6.5E-3)/4,'ro')  % sphere centered at (8.58,4.2,13.75)
    drawnow
    hold off
    
    mov(:,m) = getframe(fignum) ;
end


filename='beadsxyz';
framerate=50;
writerObj = VideoWriter(strcat(filename,'_',num2str(uint8(rand*100))),'MPEG-4');
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,mov);
close(writerObj);

set(0,'DefaultFigureWindowStyle','docked') 

toc
%{
for k=1:360
    title(sprintf('Degree %d',k));
    view(k,0)
    pause(.1)
end
%}
    
