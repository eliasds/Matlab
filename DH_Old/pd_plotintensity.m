%% Plot Particle Intensity Through focus
figure(112)
hold off
for L=2:size(intensity,2)
plot(intensity(:,1),intensity(:,L));title(['Particle# ',num2str(L-1)]);
drawnow
%hold on
pause(.3);
end
