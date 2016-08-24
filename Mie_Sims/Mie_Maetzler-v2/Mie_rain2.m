function result = Mie_rain2(fGHz, TK, R)

% Weighting functions of 
% Rain extinction, scattering, absorption, backscattering and 
% asymmetric scattering coefficient in 1/km/mm versus drop diameter
% for Marshall-Palmer (MP) size distribution (Sauvageot et al. 1992)
% using Mie Theory, and dielectric model of Liebe et al. 1991.
% Input:
% fGHz: frequency in GHz, TK: Temp. in K, R: rain rate in mm/h
% C. Mätzler, June 2002.

nsteps=501; dD=0.01*R^(1/6)/fGHz^0.05;
% nsteps: number of D values, dD: drop-size interval in mm 
m=sqrt(epswater(fGHz, TK));
N0=0.08/10000;              % original MP N0 in 1/mm^4
LA=4.1/R^0.21;
nx=(1:nsteps)';
D=(nx-1)*dD;
c0=299.793;
x=pi*D*fGHz/c0;
sigmag=pi*D.*D/4;
NMP=N0*exp(-LA*D);
sn=sigmag.*NMP*1000000;

for j = 1:nsteps
    a(j,:)=Mie(m,x(j));
end;
b(:,1)=D;
b(:,2)=a(:,1).*sn;
b(:,3)=a(:,2).*sn;
b(:,4)=a(:,3).*sn;
b(:,5)=a(:,4).*sn;
b(:,6)=a(:,2).*a(:,5).*sn;

% plotting the results
m1=real(m);m2=imag(m);
plot(b(:,1),b(:,2:6))
legend('dGext/dD','dGsca/dD','dGabs/dD','dGb/dD','d(Gsca*<costeta>)/dD')
title(sprintf('Rain Effects at f=%gGHz, T=%gK, R=%gmm/h',fGHz,TK,R))
xlabel('D (mm)');ylabel('dGi/dD (1/km/mm)')

gext= sum(b(:,2))*dD;
gsca= sum(b(:,3))*dD;
gabs= sum(b(:,4))*dD;
gb=   sum(b(:,5))*dD;
gteta=sum(b(:,6))*dD;

result=[gext gsca gabs gb gteta];