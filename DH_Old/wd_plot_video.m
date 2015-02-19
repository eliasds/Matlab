set(0,'DefaultFigureWindowStyle','normal') 
tic
filename={'DH-','mat'};
framerate=30;
a=1; % Starting file/frame
b=400; % Ending file/frame
c=1+b-a; %Number of frames
thlevel=0.1;
figurenum=40;
erodenum=1;
dilatenum=3;
eps=5.5E-6;
matsizex=2000;
matsizey=1088;
fignum = figure('Position',[10,50,1200,600],'color','w');
ca = .078;

%{
%% Convert data from pixel number to mm
matsizex=matsizex*eps;
matsizey=matsizey*eps;


eval(['filenames = dir(''' filename{1} '*.' filename{2} ''');']);
numfiles = length(filenames);

%%
for L=a:b
    load(filenames(L, 1).name);

    th = Imin<thlevel;
    th = imerode(th,ones(erodenum)); %looks in neighborhood of ero area
    th = imdilate(th,ones(dilatenum));
    zth = zeros(size(zmap));
    zth(th) = zmap(th);
    cb = max(zth(:));
    imagesc(zth,[ca,cb])
    
     %axis([0,matsizex,0,matsizey]);
     xlabel('X (pixels)')
     ylabel('Y (pixels)')
     title(['Time:',num2str(L)]);
     t = colorbar;
     set(get(t,'ylabel'),'string','Z Depth(m)','fontsize',16)
    
    mov(:,L) = getframe(fignum) ;
end
%}

filename='whiskers';
writerObj = VideoWriter(strcat(filename,'_',num2str(uint8(rand*100))),'MPEG-4');
writerObj.FrameRate = framerate;
open(writerObj);
writeVideo(writerObj,mov);
close(writerObj);

set(0,'DefaultFigureWindowStyle','docked') 

toc
    
