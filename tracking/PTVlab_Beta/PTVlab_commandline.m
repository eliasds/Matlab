% Example script how to use PTVlab from the commandline
% You can adjust the settings in "s" and "p", specify a mask and a region of interest
clc; clear all

%% Create list of images inside specified directory
directory=uigetdir; %directory containing the images you want to analyze
suffix='*.tif'; %*.bmp or *.tif or *.jpg
direc = dir([directory,filesep,suffix]); filenames={};
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames); %sort all image files
amount = length(filenames);

%% Standard PTV Settings
s = cell(10,2); % To make it more readable, let's create a "settings table"
%Parameter                       %Setting           %Options
s{1,1}= 'Int. area 1';           s{1,2}=32;         % window size of first pass
s{2,1}= 'Step size 1';           s{2,2}=16;         % step of first pass
s{3,1}= 'Subpix. finder';        s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                  s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
s{5,1}= 'ROI';                   s{5,2}=[];         % Region of interest: [x,y,width,height] in pixels, may be left empty
s{6,1}= 'Nr. of passes';         s{6,2}=3;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';           s{7,2}=32;         % second pass window size
s{8,1}= 'Int. area 3';           s{8,2}=16;         % third pass window size
s{9,1}= 'Int. area 4';           s{9,2}=16;         % fourth pass window size
s{10,1}='Window deformation';    s{10,2}='*linear'; % '*spline' is more accurate, but slower

%% Standard image preprocessing settings
p = cell(8,1);
%Parameter                       %Setting           %Options
p{1,1}= 'ROI';                   p{1,2}=s{5,2};     % same as in PIV settings
p{2,1}= 'CLAHE';                 p{2,2}=1;          % 1 = enable CLAHE (contrast enhancement), 0 = disable
p{3,1}= 'CLAHE size';            p{3,2}=50;         % CLAHE window size
p{4,1}= 'Highpass';              p{4,2}=0;          % 1 = enable highpass, 0 = disable
p{5,1}= 'Highpass size';         p{5,2}=15;         % highpass size
p{6,1}= 'Clipping';              p{6,2}=0;          % 1 = enable clipping, 0 = disable
p{7,1}= 'Clipping thresh.';      p{7,2}=0;          % 0-255 clipping threshold
p{8,1}= 'Intensity Capping';     p{8,2}=0;          % 1 = enable intensity capping, 0 = disable

%% PIV analysis loop
if mod(amount,2) == 1 %Uneven number of images?
    disp('Image folder should contain an even number of images.')
    %remove last image from list
    amount=amount-1;
    filenames(size(filenames,1))=[];
end
x=cell(amount/2,1);
y=x;
u=x;
v=x;
typevector=x; %typevector will be 1 for regular vectors, 0 for masked areas
counter=0;
tic
for i=1:2:amount
    counter=counter+1;
    image1=imread(fullfile(directory, filenames{i})); % read images
    image2=imread(fullfile(directory, filenames{i+1}));
    image1 = PTVlab_preproc (image1,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2}); %preprocess images
    image2 = PTVlab_preproc (image2,p{1,2},p{2,2},p{3,2},p{4,2},p{5,2},p{6,2},p{7,2},p{8,2});
    [x{counter} y{counter} u{counter} v{counter} typevector{counter}] = piv_FFTmulti (image1,image2,s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2});
    %% Graphical output (disable to improve speed)
    %%{
    imagesc(double(image1)+double(image2));colormap('gray');
    hold on
    quiver(x{counter},y{counter},u{counter},v{counter},'g','AutoScaleFactor', 1.5);
    hold off;
    axis image;
    title(filenames{i},'interpreter','none')
    set(gca,'xtick',[],'ytick',[])
    drawnow;
    %%}
    zeit=toc;
    done=counter;
    tocome=(amount/2)-done;
    zeit=zeit/done*tocome;
    hrs=zeit/60^2;
    mins=(hrs-floor(hrs))*60;
    secs=(mins-floor(mins))*60;
    hrs=floor(hrs);mins=floor(mins);secs=floor(secs);
    clc
    disp(['Progress: ' num2str(round(counter/(amount/2)*1000)/10) '%'])
    disp(['Image pair nr. ' num2str(counter) ' of ' num2str(amount/2)])
    disp (['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
end
hrs=toc/60^2;
mins=(hrs-floor(hrs))*60;
secs=(mins-floor(mins))*60;
hrs=floor(hrs);mins=floor(mins);secs=floor(secs);
disp(['DONE. Total elapsed time: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's'])
clearvars -except p s x y u v typevector directory filenames