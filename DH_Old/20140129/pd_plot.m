%% Plot 3D Particle information
% Version 1.0

%load('1E-5Dilute-30th_2er512size.mat');fignum=20;
%load('1E-5Dilute-35th_2er512size.mat');fignum=21;
%load('1E-5Dilute-40th_2er512size.mat');fignum=22;
%%load('1E-5Dilute-30th_3er512size.mat');fignum=23; %the one
%load('1E-5Dilute-35th_3er512size.mat');fignum=24;
%load('1E-5Dilute-40th_3er512size.mat');fignum=25;
%load('DH__80th_3er2048size.mat');
%load('DH__70th_4er2048size.mat');
fignum=19;
a=0.0E-3;
b=12E-3;
c=size(beadxyz,2)/1;
d=round(c/1.1);
matsizex=2560;
matsizey=2160;
figure(fignum)
%clear beadxyz;beadxyz=E1;
    
for m=1:c
    %figure(fignum)
    plot3(beadxyz(m).time(:,1),beadxyz(m).time(:,3),beadxyz(m).time(:,2),'b.');
    axis([0,matsizex,a,b,0,matsizey]);
    view(15,15) % small perspective in z
    %view(0,0) %flat
    %view(-38+3*m-3,30+3*m-3)
    %view(-38+m/10,30)
    %view(-34,56)
    title(['Time:',num2str(m)]);
    grid on
    box on
    hold on
    if m>d
        drawnow
    end
    %pause(0.1)
    %hold off
end
hold off