function diffinput
fid = fopen('r1.txt','r');
t = 1
A = fscanf(fid,'%f');
fclose(fid);
[m,n]= size(A)
for i = 1:m-1
delx(i)= A(i+t)-A(i)
fid = fopen('delx.txt','a+') 
fprintf(fid,' %12.3f\n',delx(i));
end
%fid = fopen('delx.txt','r') 
%Pd = fscanf(fid,' %12.3f ');
%fclose(fid)
delx
figure,histfit(delx,20)
[mu,sigma]= normfit(delx)
D = sigma/(0.6*m)  % unit of D depending on the units in r.txt


danku