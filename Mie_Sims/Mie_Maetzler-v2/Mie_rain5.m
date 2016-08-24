function result = Mie_rain5(fGHz, R, nrain)

% Extinction, scattering, absorption, backscattering and 
% asymmetric scattering coefficients in 1/km versus Temperature, 
% for Marshall-Palmer (MP) drop-size distribution 
% see Sauvageot et al. (1992), 
% using Mie Theory, Input:
% fGHz: frequency in GHz, TK: Temp. in K, 
% nrain: Number of temperatrures
% C. Mätzler, June 2002.

Tmin=270;   
nsteps=501;
N0=0.08/10000;              % original MP N0 in 1/mm^4
TK=Tmin;
nx=(1:nsteps)';
c0=299.793;
for jr = 1:nrain
    TK=TK+1;
    m=sqrt(epswater(fGHz, TK));
    dD=0.01*R^(1/6)/fGHz^0.05;
    D=(nx-1)*dD;
    x=pi*D*fGHz/c0;
    sigmag=pi*D.*D/4;
    LA=4.1/R^0.21;
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
    gext= sum(b(:,2))*dD;
    gsca= sum(b(:,3))*dD;
    gabs= sum(b(:,4))*dD;
    gb=   sum(b(:,5))*dD;
    gteta=sum(b(:,6))*dD;
    res(jr,:)=[TK gext gsca gabs gb gteta];
end;
output_parameters='Gext, Gsca, Gabs, Gb, Gsca*<costeta>'
plot(res(:,1),res(:,2:6))
legend('Gext','Gsca','Gabs','Gb','Gsca*<costeta>')
title(sprintf(' Propagation Coef. vs. Temperature at f=%gGHz, R=%gmm/h',fGHz,R))
xlabel('T (K)');    ylabel('Gi(1/km)')
result=res;
