%% Create a 3D matrix of point particles with trajectories
clear all;

frames=200; %number of timesteps
particles=100; %number of test particles

beadtest(frames) = struct('time',[]);
X=2560*6.5E-6/4; %max x position(m)
Y=2160*6.5E-6/4; %max y position(m)
Z=10E-3; %max z position(m)
T=0;

% incremental displacement
dt=0.01;
dy=0;
dz=0;

Vx=6E-6;
Vy=0E-6;
Vz=0E-6;

Ax=0E-6;
Ay=11E-6;
Az=15E-6;

% randomize initial particle positions
a=(X).*rand(particles,1);
a=cat(1,a,a+3E-6*rand,a+3E-6*rand,a+3E-6*rand);
b=(Y).*rand(particles,1);
b=cat(1,b,b+3E-5*rand,b+3E-5*rand,b+3E-6*rand);
c=(Z).*rand(particles,1);
c=cat(1,c,c+3E-6*rand,c+3E-6*rand,c+3E-6*rand);
beadtest(1).time(:,1) = a;
beadtest(1).time(:,2) = b;
beadtest(1).time(:,3) = c;

%randbead=ones(40,1);

%randbead2=1E-6.*rand(4*particles,1);


% apply trajectory
for L=2:frames;
    T=T+dt;
    
    dx=Vx*T + 0.5*Ax*T^2 + 1E-6.*rand(4*particles,1);
    beadtest(L).time(:,1) = beadtest(L-1).time(:,1) + dx;
    wrap = beadtest(L).time(:,1) < X;
    beadtest(L).time(:,1) = beadtest(L).time(:,1) .* wrap;
    
    dy=Vy*T + 0.5*Ay*T^2 + 1E-6.*rand(4*particles,1);
    beadtest(L).time(:,2) = beadtest(L-1).time(:,2) + dy;
    wrap = beadtest(L).time(:,2) < Y;
    beadtest(L).time(:,2) = beadtest(L).time(:,2) .* wrap;
    
    dz=Vz*T + 0.5*Az*T^2 + 1E-6.*rand(4*particles,1);
    beadtest(L).time(:,3) = beadtest(L-1).time(:,3) + dz;
    wrap = beadtest(L).time(:,3) < Z;
    beadtest(L).time(:,3) = beadtest(L).time(:,3) .* wrap;
end



%% Plotting
for L=1:frames
    view(0,180); % set(get(gca,'YLabel'),'Rotation',0.0) %flat
    plot3(beadtest(L).time(:,1),beadtest(L).time(:,3),beadtest(L).time(:,2),'b.');
    title(['Time:',num2str(L)]);
    hold on
end
hold off