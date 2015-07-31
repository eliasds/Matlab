figure()

p = 12;
n = 2000;
size_w = 750; % size of window
a1 = 0.1;
linecolor = 'k'; % color of spiral

%Simple Spiral
t = linspace(0,p*pi,n);
x_1 = -a1*t.^3.*sin(t);
y_1 = -a1*t.^3.*cos(t);

x_2 = a1*t.^3.*sin(t);
y_2 = a1*t.^3.*cos(t);

hold on

% h = plot(x_1, y_1, linecolor);
h = plot(x_1,y_1,linecolor, x_2, y_2,linecolor);
set(gca, 'Units', 'Pixels');
set(gca, 'Position', [1 1 size_w+1 size_w+1])
set(gcf, 'OuterPosition', [0 0 size_w+18 size_w+110])
axis([-size_w/2 size_w/2 -size_w/2 size_w/2]);
% axis image
% axis off