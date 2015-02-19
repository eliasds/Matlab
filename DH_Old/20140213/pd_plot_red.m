tic
%load('1E-5Dilute-30th_2er512size.mat');fignum=20;
%load('1E-5Dilute-35th_2er512size.mat');fignum=21;
%load('1E-5Dilute-40th_2er512size.mat');fignum=22;
%%load('1E-5Dilute-30th_3er512size.mat');fignum=23; %the one
%load('1E-5Dilute-35th_3er512size.mat');fignum=24;
%load('1E-5Dilute-40th_3er512size.mat');fignum=25;
%load('DH__80th_3er2048size.mat');
%load('DH__70th_4er2048size.mat');
eps=6.5E-3/4; % mm
fignum=19;
a=0.0E-3;
b=12E-3;
c=size(beadxyz,2)/1;
d=round(c/1.5);
d=0;
matsizex=2560;
matsizey=2160;
figure(fignum)
%clear beadxyz;beadxyz=E1;

%% Convert data from pixel number to mm
beadxyzmm=beadxyz;
a=0.0;
b=12;
matsizex=matsizex*eps;
matsizey=matsizey*eps;


for m=1:size(beadxyz,2)
    beadxyzmm(m).time(:,1:2)=eps*beadxyz(m).time(:,1:2);
    beadxyzmm(m).time(:,3)=1E3*beadxyz(m).time(:,3);
end

%%
plot3(beadxyzmm(1).time(:,1),beadxyzmm(1).time(:,3),beadxyzmm(1).time(:,2),'b.');
axis([0,matsizex,a,b,0,matsizey]);
xlabel('(mm)')
ylabel('Through Focus (mm)')
zlabel('(mm)')
grid on
box on
view(15,15); set(get(gca,'YLabel'),'Rotation',30.0) % small perspective in z
%view(0,180); % set(get(gca,'YLabel'),'Rotation',0.0) %flat
title('Time:1');
hold on
[x,y,z] = sphere(200);
plot3(0.13*x+(1240*6.5E-3)/4,1*y+4.5,0.1*z+(2040*6.5E-3)/4,'ro')  % sphere centered at (8.58,4.2,13.75)
drawnow

%%    
for m=1:c
    %figure(fignum)
    plot3(beadxyzmm(m).time(:,1),beadxyzmm(m).time(:,3),beadxyzmm(m).time(:,2),'b.');
    %axis([0,matsizex,a,b,0,matsizey]);
    axis([0,matsizex,a,b,0,matsizey]);
    %view(15,15); set(get(gca,'YLabel'),'Rotation',30.0) % small perspective in z
    %view(0,180); % set(get(gca,'YLabel'),'Rotation',0.0) %flat
    %view(-38+3*m-3,30+3*m-3)
    %view(-38+m/10,30)
    title(['Time:',num2str(m)]);
    hold on
    if m > d
        drawnow
    end
    %pause(0.1)
    %hold off
end
hold off
toc