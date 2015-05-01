%trial and error method of determining NA when theta is unknown going
%through two mediums

equ = 'd1*tan(theta) + d2*n1/n2*sqrt(sin(theta)^2/(1-(n1/n2)^2*sin(theta)^2))';

theta=1.0286;d1=5;d2=0;n1=1.33;n2=1;NA=n1*sin(theta);L=eval(equ)

%%Adjust theta and the rest of your pareameters
% until L(half the size of you camera/aperture) is correct
% then NA will also be correct
