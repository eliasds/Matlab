sprintf('Running GitHub Startup')

% Add to Path
addpath('D:\shuldman\GitHub\holography','D:\shuldman\GitHub\Matlab',...
    'D:\shuldman\GitHub\Matlab\Spirals',...
    'D:\shuldman\GitHub\Matlab\plotting',...
    'D:\shuldman\GitHub\Matlab\Camille');
    
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
set(0,'DefaultTextInterpreter','none');

% for creating a cartesian coordinate system
% set(gca,'YDir','normal');

rehash toolboxcache