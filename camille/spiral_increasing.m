figure()

p = 12;
n = 2000;
size_w = 750; % size of window
a1 = 1E-2;
b1 = 3;
a2 = 1E-2;
b2 = b1;
linecolor = 'k'; % color of spiral

%Simple Spiral
t = linspace(0,p*pi,n);
x_1 = -1*a1*t.^b1.*sin(t);
y_1 = -1*a1*t.^b1.*cos(t);

x_2 = a2*t.^(b2).*sin(t);
y_2 = a2*t.^(b2).*cos(t);

hold on

% h = plot(x_1, y_1, linecolor);
h = plot(x_1,y_1,linecolor, x_2, y_2,linecolor);
set(gca, 'Units', 'Pixels');
set(gca, 'Position', [1 1 size_w+1 size_w+1])
set(gcf, 'OuterPosition', [0 0 size_w+18 size_w+110])
axis([-size_w/2 size_w/2 -size_w/2 size_w/2]);
handle = title(['p=',num2str(p),' n=',num2str(n),' sizew=',num2str(size_w),' a1=',num2str(a1),' b1=',num2str(b1),' a2=',num2str(a2),' b2=',num2str(b2)]);
set(handle,'Position',[0,100]);
% axis image
axis off