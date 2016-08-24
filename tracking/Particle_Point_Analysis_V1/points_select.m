function points_select()
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

[xo,yo]=ginput();

disp(xo);
disp(yo);

axis([0 10 0 10])
hold on
% Initially, the list of points is empty.
xy = [];
n = 0;
% Loop, picking up the points.
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;

while but ~=13
    [xi,yi,but] = ginput(1);
    if but==1
        plot(xi,yi,'bo')
        n = n+1;
        xy(:,n) = [xi;yi];
    else if but==3
        TRI=delaunay(xy(1,:),xy(2,:));
        K = dsearch(xy(1,:),xy(2,:),TRI,xi,yi);
        plot(xy(1,K),xy(2,K),'ro')
        plot(xy(1,K),xy(2,K),'rx')
        xy = [xy(:,1:K-1) xy(:,K+1:n)];
        n=n-1;
        plot(xy(1,:),xy(2,:),'bo');
        end
    end
end

%while but == 1
%    [xi,yi,but] = ginput(1);
%    plot(xi,yi,'bo')
%    n = n+1;
%    xy(:,n) = [xi;yi];
%end
% Interpolate with a spline curve and finer spacing.
t = 1:n;
ts = 1: 0.1: n;
xys = spline(t,xy,ts);

% Plot the interpolated curve.
plot(xys(1,:),xys(2,:),'b-');
hold off