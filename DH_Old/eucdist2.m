function d2=eucdist2(a,b)
%
% Usage: D2=eucdist2(A,B)
%
% Finds the *squared* Euclidean distance between two sets of data points A
% and B.  The data arrays are assumed to have observations along the rows
% and columns as dimensions.  Note that A and B may have different numbers
% of observations, but must have the same number of dimensions.
% 
% The returned array, D2, is the square of the Euclidean distance.
% Specifically, sqrt(D2(n,m)) represents the distance from A(n) and B(m).
% Since many applications require a distance ordering only, I'm saving a
% few computations by skipping the sqrt computation for every element of
% the array.
%

% This function is based on Roland Bunschoten's distance.m function, which
% uses the same vectorized approach to quickly calculate distances.  The
% function is available through Matlab Central.

% NL, 2008


[n,d]=size(a);
[m,d2]=size(b); 

if d~=d2
    error('The arrays must have the same number of dimensions.');
end

%Idea: write d2=sum(a^2+b^2-a*b,d) in a vectorizable format.

a2=sum(a.^2,2); %size nx1
b2=sum(b.^2,2); %size mx1
a2=repmat(a2,[1,m]);
b2=repmat(b2',[n,1]);
d2=a2+b2-2*a*b';
d2=sqrt(d2);
%d2=a2*ones(1,m)+ones(n,1)*b2'-2*a*b';