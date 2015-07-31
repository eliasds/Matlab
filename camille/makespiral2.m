close all

p = 12;
n = 2000;
size_w = 750; % size of window
size_s = 100; % size of spiral
a1 = size_s/pi;
shift = size_s;
color = 'k'; % color of spiral

%Simple Spiral
t = linspace(0,p*pi,n);
x_1 = -a1*t.*sin(t);
y_1 = -a1*t.*cos(t);

t_2 = linspace(pi, p*pi,n);
x_2 = -a1*t_2.*sin(t_2) + shift*sin(t_2);
y_2 = -a1*t_2.*cos(t_2) + shift*cos(t_2);

X=[x_1,fliplr(x_2)];
Y=[y_1,fliplr(y_2)];
fill(X,Y,color);

hold on
h = plot(x_1,y_1, x_2, y_2);
set(h, 'Color', color);
set(gca, 'Units', 'Pixels');
set(gca, 'Position', [0 0 size_w size_w])
set(gcf, 'OuterPosition', [0 0 2*size_w 2*size_w])
axis([-size_w/2 size_w/2 -size_w/2 size_w/2]);
