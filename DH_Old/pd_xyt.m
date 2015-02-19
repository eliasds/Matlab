%%
% 
% Version 1.0

dirname = '';
filename    = '40x75_6lens2-12mm_';
background = 'background.mat';
M=75.6/9; %Magnification
eps=6.5E-6 / M; %Effective Pixel Size in meters
a=0;
b=7E-3;
c=700;
thlevel=0.75;
erodenum=5;
radix2=1024;
    

filename = strcat(dirname,filename);
filesort = dir([filename,'*.tif']);
numfiles = numel(filesort);
varnam=who('-file',background);
background=load(background,varnam{1});
background=background.(varnam{1});

%numfiles=24;
%E1=struct('time',{});
E1(numfiles).time=[];
%wb = waitbar(1/numfiles,['Analysing Data']);
matlabpool open 12
parfor i=1:numfiles % FYI: for loops always reset 'i' values.
    i
    % import data from tif files.
    E0 = (double(imread([filesort(i).name]))./background);
    center=round(size(E0)/2);
    E0=E0((center(1)+1-radix2/2):(center(1)+radix2/2),(center(2)+1-radix2/2):(center(2)+radix2/2));

    [Imin, zmap] = fp_minint(E0, a, b, c, 632.8e-9, eps);
    Iminth = Imin<thlevel;
    zth = zeros(size(zmap));
    zth(Iminth) = zmap(Iminth);
    [Xauto,Yauto] = pd_auto(Imin, thlevel, erodenum);
    E1(i).time=[Xauto;Yauto]';
    
    
%    waitbar(i/numfiles,wb);
end

matlabpool close;
%close(wb);

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

    