sprintf('Running GitHub Startup')

try
cd d:
end


% Add Github to Path
try
    addpath('D:\shuldman\GitHub\holography',...
        'D:\shuldman\GitHub\holography\kd_tree',...
        'D:\shuldman\GitHub\Matlab',...
        'D:\shuldman\GitHub\Matlab\plotting',...
        'D:\shuldman\GitHub\Matlab\holography',...
        'D:\shuldman\GitHub\Matlab\Camille');
catch
    disp('github path has moved');
end

% Add micromanager to Path
try
    addpath('C:\Program Files\Micro-Manager-1.4');
catch
    disp('micromanager is unavailable');
end

    
% Remove confusing path
warning('off','all')
rmpath(genpath('X:\Volker\Dropbox\code and data'));
warning('on','all')

% Change default axes fonts.
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 18)
set(0,'DefaultAxesFontWeight','bold')

% Change default text fonts.
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultTextFontSize', 18)
set(0,'DefaultTextFontWeight','bold')

% Set default figures to 'docked' or 'normal'
set(0,'DefaultFigureWindowStyle','docked')

% Ignore '^' interpretation in titles
% title(a,'Interpreter','none');
% set(0,'DefaultTextInterpreter','none');

% for creating a cartesian coordinate system
% set(gca,'YDir','normal');

% Create 'blacklines' colormap
tempfig = figure(999999);
blacklines = colormap(lines);
blacklines(1,1:3)=0;
close(tempfig)

rehash toolboxcache