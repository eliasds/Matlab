function y=MyL1phi(x)

X=MyV2C(x(:));

y=sum(sqrt(real(X).^2+imag(X).^2));
