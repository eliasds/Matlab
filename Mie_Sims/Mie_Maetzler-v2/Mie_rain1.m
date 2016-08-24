function result = Mie_rain1(fGHz, TK, nsteps, dD)

% Efficiencies of rain extinction, scattering, absorption 
% backscattering and asymmetric scattering, using Mie Theory and
% the dielectric model of Liebe et al. (1991), see epswater.
% Input: fGHz frequency in GHz, TK temperature in K, nsteps number
% of diameters (D in mm), dD increment of diameter in mm 
% C. Mätzler, June 2002

m=sqrt(epswater(fGHz, TK));
nx=(1:nsteps)';
D=(nx-1)*dD;
c0=299.793;
x=pi*D*fGHz/c0;

for j = 1:nsteps
    a(j,:)=Mie(m,x(j));
end;
output_parameters='Qext, Qsca, Qabs, Qb, <costeta>'

% plotting the results
m1=real(m);m2=imag(m);
plot(D,a(:,1:5))
legend('Qext','Qsca','Qabs','Qb','<costeta>')
title(sprintf('Mie Efficiencies for raindrops f=%gGHz, T=%gK, m=%g+%gi',fGHz,TK,m1,m2))
xlabel('D (mm)')
ylabel('Mie Efficiency')

result=a; 