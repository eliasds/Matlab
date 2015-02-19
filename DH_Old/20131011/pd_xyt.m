%%
% 
% Version 1.0

dirname = '';
filename    = '40x75_6lens2-12mm_';
background = 'background.mat';
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=0;
b=2E-3;
c=20;
thlevel=0.75;
erodenum=5;
radix2=1024;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
varnam=who('-file',background);
background=load(background,varnam{1});
background=background.(varnam{1});

numfiles=10;
E1(numfiles).time=[];
wb = waitbar(1/numfiles,['Analysing Data']);
for i=1:numfiles % FYI: for loops always reset 'i' values.

    % import data from tif files.
    E0 = (double(imread([filesort(i).name]))./background);
    center=round(size(E0)/2);
    E0=E0((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));

    [Imin, zmap] = fp_minint(E0, a, b, c, 632.8e-9, eps);
    %Iminth = Imin<thlevel;
    %zth = zeros(size(zmap));
    %zth(Iminth) = zmap(Iminth);
    [Xauto,Yauto,Zauto_interp,Zauto_centroid,Zauto_value] = pd_auto(Imin, zmap, thlevel, erodenum);
    E1(i).time=[Xauto;Yauto;Zauto_interp;Zauto_centroid;Zauto_value]';
    
    
    waitbar(i/numfiles,wb);
end

close(wb);

figure(1)
for i=1:numfiles
    plot3(E1(i).time(:,1),E1(i).time(:,2),E1(i).time(:,3),'b.');
    axis([0,radix2,0,radix2,a,b]);
    view(-38+i,30+i)
    grid on
    box on
    hold on
    drawnow
    pause(0.1)
    plot3(E1(i).time(:,1),E1(i).time(:,2),E1(i).time(:,4),'g.');
    view(-38+i+1,30+i+1)
    drawnow
        pause(0.1)
    plot3(E1(i).time(:,1),E1(i).time(:,2),E1(i).time(:,5),'r.');
    view(-38+i+2,30+i)
    drawnow
    pause(0.5);
        pause(0.1)
    hold off
    endr

%{
figure(1)
for i=1:numfiles
    for j=1:numel(E1(i).time)/2
        plot(E1(i).time(j,1),E1(i).time(j,2),'b.');
        axis([0,radix2,0,radix2]);
        hold on
    end
    pause(.5);
    hold off
end
%}
    