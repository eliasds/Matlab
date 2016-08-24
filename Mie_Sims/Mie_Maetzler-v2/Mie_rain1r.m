function result = Mie_rain1r(fGHz, TK, nsteps, dD)

% Comparison of Efficiencies of rain extinction, scattering, absorption 
% backscattering and asymmetric scattering, 
% between Mie and Rayleigh Theory
% Input: fGHz frequency in GHz, TK temperature in K, nsteps number
% of diameters (D in mm), dD increament of diameter in mm 
% C. Mätzler, June 2002

m=sqrt(epswater(fGHz, TK))
nx=(1:nsteps)';
D=(nx-1)*dD;
c0=299.793;
x=pi*D*fGHz/c0;

for j = 1:nsteps
    a(j,:)=Mie(m,x(j));
    ar(j,:)=Mie_1(m,x(j));
end;

% plotting the results
loglog(D,a(:,2),'b -',D,ar(:,2),'b.',D,a(:,3),'r -',D,ar(:,3),'r.',D,a(:,4),'c -',D,ar(:,4),'c.')
legend('QscaM','QscaR','QabsM','QabsR','QbM','QbR')
title(sprintf('Mie and Rayleigh Efficiencies of raindrops f=%gGHz, T=%gK',fGHz,TK))
xlabel('D (mm)')
ylabel('Mie Eficiency')

result=[a ar];