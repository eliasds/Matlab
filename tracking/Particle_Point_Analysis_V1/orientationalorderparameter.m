function [S]=orientationalorderparameter(x_data, y_data)


n = [1 0];
N = length(x_data);

S=0;
cnt=0;
figure;
for i=1:2:N-1
    cnt=cnt+1;
    p(cnt,:) = [x_data(i)-x_data(i+1) y_data(i)-y_data(i+1)]/norm([x_data(i)-x_data(i+1) y_data(i)-y_data(i+1)]);
    arrow3([0 0], p(cnt,:));
    hold on;
end

axis equal;

for i=1:cnt
    S = S+ dot(n,p(cnt,:));
end

S= (3*S/N - 1)/2





