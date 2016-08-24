function result = epswater(fGHz, TK)

% Dielectric permittivity of liquid water without salt according
% to Liebe et al. 1991 Int. J. IR+mm Waves 12(12), 659-675
% Frequency range: 1 to 1000 GHz, temperature range: 270 to 310 K,
% extended 250 to 330 K 
% Input: fGHz: frequency in GHz, TK: temperature in K
% Mätzler, June 2002

TETA=1-300/TK;
e0=77.66-103.3*TETA;
e1=0.0671*e0;
f1=20.2+146.4*TETA+316*TETA.*TETA;
e2=3.52+7.52*TETA;  
% version of Liebe 1993 uses: e2=3.52
f2=39.8*f1;
eps=e2+(e1-e2)./(1-i*fGHz./f2)+(e0-e1)./(1-i*fGHz./f1);

result=eps; 