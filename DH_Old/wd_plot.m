%% Plot 3D Particle information
% Version 1.0

fignum=20;
figure(fignum)

for m=1:100
    %figure(fignum)
    wd_3dplot(whiskers(m).time,0.025)
    title(['Time:',num2str(m)]);
    grid on
    box on
    drawnow
    %hold on
    %pause(0.1)
    %hold off
end
%hold off