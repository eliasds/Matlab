% Particle Detection in 3D using minimum intensity thresholding

clear all, close all       % Clear everything each run

% Make sure the Matlab working directory is the one your images are in


% Read all tif files from directory
D = dir('cuvecuvette-35-47mm-50us_005*.tif');

imcell = cell(1, numel(D));     % Create a cell for each image in directory

% Load all the images from directory
for i = 1:numel(D)
   imcell{i} = fp_imload(D(i).name);
end

% Load the parameters file. Loads the following variables
%     camPixelSize - pixel size of camera sensor pixels in microns
%     magnification - magnification from 4f system
%     wavelength - Laser wavelength in nanometers (nm)
try
    load parameters.mat  
    
% If the parameters file does not exist, use default parameters
catch exception
    if ~exist('parameters.mat', 'file')
        disp('CAUTION: Could not load parameters file. Default values used.');
        
        camPixelSize = 6.5;     % Default camera pixel size in microns
        magnification = 1;  % Default magnification 
        wavelength = 632.8;       % Default wavelength in nm
       
    end
end

% Variables and Camera Parameters
zEst = 39E-3;                             % Estimated z-value in meters
range = 0.5E-3;                           % Range on either side of estimated z-value in meters
numSteps = 50;                           % Number of steps
pixel_size = camPixelSize/magnification;  % Magnified pixel size in microns
pixels_x = 2560;                          % Number of pixels in width of image
pixels_y = 2160;                          % Number of pixels in height of image
loop=0;


a = zEst - range;    % Close range of z-values in m
b = zEst + range;    % Far range of z-values in m
c = numSteps;                        % Number of steps

particleRGBthreshold = 75.634;

detectedParticles = cell(1, numel(D));

% Turn on profiling to check computation time
profile on

%{
% Enable parallel computing for processing images
if matlabpool('size') == 0          % Make sure pool isn't already open
    matlabpool open local 4                 % Open matlabpool
    %matlabpool local 4              % Number of workers as cores on machine
end
%}


%parfor k = 1:numel(D) %for parallel processing
for k = 1:numel(D) %for nonparallel computing
    
    img = imcell{k};
    
    %disp(k); %metric for progress completed
    
    particlesImage = [];

    for z = a:(b-a)/(c-1):b   
        
        Ef = fp_fresnelprop(img, wavelength, z, pixel_size);
    
        % Crop resultant image to square at center of image
        %Ef = CropImageSquare(Ef, 1024);
        
        Ef=abs(Ef);
        [row,col] = find(Ef < particleRGBthreshold);
    
        particlesImage = [particlesImage; col,row,ones(length(row),1)*z];
        
        %another metric for progress completed
        loop=loop+1; if rem(10*loop/numel(D),c)==0 || rem(c,loop/numel(D))==0; fprintf('Percentage complete:');disp(100*loop/c/numel(D)); end
    

    end
    
    detectedParticles{k} = particlesImage;

end


% End parallel computing
%matlabpool close

%
% Turn off profiling and save results to file
profile viewer
p = profile('info');
profsave(p, 'profile_results')
%


%%
%
%Plot Detected Particles
figure(99);
for i = 1 : numel(detectedParticles)
    scatter3(detectedParticles{i}(:,3), detectedParticles{i}(:,1), detectedParticles{i}(:,2),'fill'), ...
        title('Particles Moving in Time'), xlabel('Z'), ylabel('X'), zlabel('Y');, axis([a b 0 512 0 512]);%, view(90,0);
    pause(0.5);
end
%