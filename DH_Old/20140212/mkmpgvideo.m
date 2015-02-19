filename={'filename','tif'};
framerate=5;
eval(['filenames = dir(''' filename{1} '*.' filename{2} ''');']);
numfiles = length(filenames);
E0=double(imread(filenames(1, 1).name));
[m,n]=size(E0);
clear F; F(numfiles) = struct('cdata',[],'colormap',[]);%Preallocate video array
writerObj = VideoWriter(strcat(filename{1},'_',num2str(uint8(rand*100))),'MPEG-4'); %350sec for 100 frames
writerObj.FrameRate = framerate;
open(writerObj);
for L=1:numfiles
    E0=double(imread(filenames(L, 1).name));
    F(L).cdata=uint8(zeros(m,n,3));
    F(L).cdata(:,:,1)=uint8(abs(E0));
    F(L).cdata(:,:,2)=F(L).cdata(:,:,1);
    F(L).cdata(:,:,3)=F(L).cdata(:,:,1);
    writeVideo(writerObj,F(L));
end
close(writerObj);
