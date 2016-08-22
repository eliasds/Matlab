function whiskers = wd_run_evan(frames, background, thlevel, erodedim, erodedir, numsteps, a, b, cropdim)
%% List of constants and scripts to run whisker detection
%
defaultdirectory = cd;

if ~exist('frames','var') || isempty(frames)
    [f,p] = uigetfile({'*.seq'}, 'Choose Image file',defaultdirectory,...
        'Multiselect', 'off');
    if f==0 % user hit cancel
        return
    end
    [~, frames] = Norpix2MATLAB(fullfile(p,f));
elseif ischar(frames)
    [~, frames] = Norpix2MATLAB(frames);
end

if ~exist('background','var') || isempty(background)
    [f,p] = uigetfile({'*.mat'}, 'Choose background file',defaultdirectory,...
        'Multiselect', 'off');
    if f==0 % user hit cancel
        background = true;
    else
        background = load(fullfile(p,f));
        background = background.background;
    end
elseif ischar(background) %filename input
    background = load(background);
    background = background.background;
end
if background == true
    background = mean(frames,3);
end

if ~exist('thlevel','var') || isempty(thlevel)
    thlevel = 0.05;
end
if ~exist('erodedim','var') || isempty(erodedim)
    erodedim = 3;
end
if ~exist('erodedir','var') || isempty(erodedir)
    erodedir = 'Vertical';
end
if ~exist('numsteps','var') || isempty(numsteps)
    numsteps = 100;
end
if ~exist('a','var') || isempty(a)
    a = 70E-03;
end
if ~exist('b','var') || isempty(b)
    b = 90E-03;
end
if ~exist('cropdim','var')
    xcrop1 = 1;
    xcrop2 = 1968;
    ycrop1 = 1;
    ycrop2 = 1088;
else
    xcrop1 = cropdim(1);
    xcrop2 = cropdim(2);
    ycrop1 = cropdim(3);
    ycrop2 = cropdim(4);
end

M=0.5; %Magnification
eps=5.5E-6 / M; %Effective Pixel Size in meters
lambda=787E-9; %laser wavelength in meters
% c = 200; %1+(b-a)/10E-6;
Zin=linspace(a,b,numsteps);
Zout=Zin;
radix2=2048;
zpad=2048;
%maxint=6; %overide default max intensity: 2*mean(Imin(:))


%%
%Calculate Minimum intensity and Detect Whiskers
try
    frames = gpuArray(frames);
    background = gpuArray(background);
catch
    fprintf('could not convert images to a gpu array, too large')
end

% Divide background
% E0 = bsxfun(@rdivide, frames, background); %normalize each frame to the background (values at background intensity will be 1, values a lot smaller will be close to 0)
E0 = bsxfun(@rdivide, frames(ycrop1:ycrop2,xcrop1:xcrop2,:), background(ycrop1:ycrop2,xcrop1:xcrop2,:)); %normalize each frame to the background (values at background intensity will be 1, values a lot smaller will be close to 0)

% Subtract background
% E0 = bsxfun(@minus, frames, background); %subtract
% [H, W, t] = size(E0);
% E0 = bsxfun(@minus, E0, reshape(min(reshape(E0, H*W, t), [], 1), 1, 1, t)); %shift setting minimum to 0

if exist('maxint')<1
    maxint=2*mean(mean(E0(:,:,1)));
end
E0(E0>maxint) = maxint;
E0(isnan(E0)) = mean(background(:));

whiskers = gpuArray.zeros(size(E0)); % initialize output
numFrames = size(frames,3);
wb = waitbar(0,'Analysing Minimum Intensity and Detecting Whiskers');
tic
for L=1:numFrames % FYI: for loops always reset 'i' values.
    
    [Imin, zmap] = fp_imin(E0(:,:,L),lambda,Zout,eps,zpad); %determine minimum intensity in current frame
%     thlevel = graythresh(Imin);
    whiskers(:,:,L) = wd_auto(Imin, zmap, thlevel, erodedir, erodedim, xcrop1, xcrop2, ycrop1, ycrop2); %detect whiskers in current frame
    
    toc
    waitbar(L/numFrames,wb);
end

close(wb);
