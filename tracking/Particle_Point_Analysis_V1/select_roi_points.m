function [x_min, x_max, y_min, y_max]=select_roi_points()

k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
x_min=min(x);
x_max=max(x);
y_min=min(y);
y_max=max(y);
hold on
axis manual
p=plot(x,y);
[xi,yi,but] = ginput(1);
if but==1
    delete(p);
else if but==3
        delete(p);
    end
end
