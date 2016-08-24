% Function for calculating the relative permittivity of pure ice in the microwave region

function z = epsice(f,TK)
	
% TK = temperature (deg K)
% f = frequency in GHz

	B1 = 0.0207;
	B2 = 1.16e-11;
	b = 335;
	deltabeta = exp(-10.02 + 0.0364*(TK-273));
	betam = (B1/TK) * ( exp(b/TK) / ((exp(b/TK)-1)^2) ) + B2*f^2;
	beta = betam + deltabeta;
	theta = 300 / TK - 1;
	alfa = (0.00504 + 0.0062*theta)*exp(-22.1*theta);
	z = 3.1884 + 9.1e-4*(TK-273);
	z = z + i*(alfa/f + beta*f);
