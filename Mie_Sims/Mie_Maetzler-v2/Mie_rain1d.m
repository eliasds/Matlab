function result = Mie_rain1d(fGHz, TK, nsteps, dD)

% Efficiencies differences of rain extinction, scattering, absorption 
% backscattering and asymmetric scattering, using Mie Theory
% between the dielectric water models of Liebe 1991 and Liebe 1993
% Input: fGHz frequency in GHz, TK temperature in K, nsteps number
% of diameters (D in mm), dD increament of diameter in mm 
% C. Mätzler, June 2002

m=sqrt(epswater(fGHz, TK))
m93=sqrt(epswater93(fGHz, TK))
dm1=real(m-m93);dm2=imag(m-m93);
nx=(1:nsteps)';
D=(nx-1)*dD;
c0=299.793;
x=pi*D*fGHz/c0;

for j = 1:nsteps
    a(j,:)=Mie(m,x(j));
    a93(j,:)=Mie(m93,x(j));
    da=(a-a93);
end;

% plotting the results
plot(D,da(:,1:5))
legend('dQext','dQsca','dQabs','dQb','d<costeta>')
title(sprintf('f=%gGHz, T=%gK, m91-m93 = %g+%gi',fGHz,TK,dm1,dm2))
xlabel('D (mm)')
ylabel('Mie Eficiency Differences Liebe91-Liebe93')

result.a=a; result.a93=a93;