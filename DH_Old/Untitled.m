% tic
% fp3dabs=single(abs(fp3d));
% fp3dreal=single(real(fp3d));
% %save(strcat('3D',filesort(i).mat),'fp3d','Zout','-v7.3');
% toc

figure(303);
subplot(2,1,1)
plot(Zout,squeeze(real(fp3d(400,951,:))));title('Whisker 2 - single pixel');
ylabel('Intensity (AU)')
subplot(2,1,2)
xyint=mean(fp3d(400,950:952,:),2);
plot(Zout,squeeze(xyint));title('Whisker 2 - mean of 3 pixels');
ylabel('Intensity (AU)')
xlabel('Through Focus Position (m)')