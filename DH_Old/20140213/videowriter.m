%clear F; F(c) = struct('cdata',[],'colormap',[]);%Preallocate video array
filename='beads';
framerate=20;
loop=0;
writerObj = VideoWriter(strcat(filename,'_',num2str(uint8(rand*100))),'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,F);
close(writerObj);