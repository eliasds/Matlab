figure(300);
subplot(3,1,1)
load('/Users/eliasds/Documents/UCBerkeley/Waller Lab/Data/20131011-06um/100x400lens1-11mm5msExp1E-5Dilute/DH_0001_int_th_foc.mat')
L=26;plot(intensity(:,1),intensity(:,L));title(['6um Particle# ',num2str(L-1)]);
subplot(3,1,2)
load('/Users/eliasds/Documents/UCBerkeley/Waller Lab/Data/20131011-10um/100x400lens1-11mm5msExp5msWait1E-4Dilute16bit/DH_0001_int_th_foc.mat')
L=14;plot(intensity(:,1),intensity(:,L));title(['10um Particle# ',num2str(L-1)]);
ylabel('Intensity (AU)')
subplot(3,1,3)
load('/Users/eliasds/Documents/UCBerkeley/Waller Lab/Data/20131010-20um/100x400lens1-11mm5msExp/16bit-mult/1e-5dilute_0001_int_th_foc.mat')
L=42;plot(intensity(:,1),intensity(:,L));title(['20um Particle# ',num2str(L-1)]);
xlabel('Through Focus Position (mm)')

%%Example
%{
figure
t = 0:pi/20:2*pi;
[x,y] = meshgrid(t);
subplot(2,2,1)
plot(sin(t),cos(t)) 
axis equal
subplot(2,2,2)
z = sin(x)+cos(y);
plot(t,z)
axis([0 2*pi -2 2])
subplot(2,2,3)
z = sin(x).*cos(y);
plot(t,z)
axis([0 2*pi -1 1])
subplot(2,2,4)
z = (sin(x).^2)-(cos(y).^2);
plot(t,z)
axis([0 2*pi -1 1])
%}