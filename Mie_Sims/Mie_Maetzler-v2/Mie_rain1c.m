function result = Mie_rain1c(fGHz, TK, nsteps, dD)

% Comparison of Efficiencies of rain extinction, scattering, absorption 
% backscattering and asymmetric scattering, using Mie Theory
% between the dielectric water models of Liebe 1991 and Liebe 1993
% Input: fGHz frequency in GHz, TK temperature in K, nsteps number
% of diameters (D in mm), dD increament of diameter in mm 

m=sqrt(epswater(fGHz, TK));
m93=sqrt(epswater93(fGHz, TK));
nx=(1:nsteps)';
D=(nx-1)*dD;
c0=299.793;
x=pi*D*fGHz/c0;

for j = 1:nsteps
    a(j,:)=Mie(m,x(j));
    a93(j,:)=Mie(m93,x(j));
end;

% plotting the results
plot(D,a(:,2),'g -',D,a93(:,2),'g.-',D,a(:,3),'r -',D,a93(:,3),'r.-',D,a(:,4),'c -',D,a93(:,4),'c.-',D,a(:,5),'m -',D,a93(:,5),'m.-')
legend('Qsca','Qsca93','Qabs','Qabs93','Qb','Qb93','<costeta>','<costeta>93')
title(sprintf('Mie Efficiencies of raindrops f=%gGHz, T=%gK',fGHz,TK))
xlabel('D (mm)')
ylabel('Mie Eficiency')

result.a=a; result.a93=a93;