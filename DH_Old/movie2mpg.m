function [empty] = movie2mpg(mov, filename, framerate)


%clear F; F(c) = struct('cdata',[],'colormap',[]);%Preallocate video array
%filename='beads';
%framerate=50;
writerObj = VideoWriter(strcat(filename,'_',num2str(uint8(rand*100))),'MPEG-4');
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,mov);
close(writerObj);