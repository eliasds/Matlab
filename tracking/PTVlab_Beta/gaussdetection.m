function [i,j]=gaussdetection(ima,corrcut,sigma,tl,A,B)
%gaussdetection() function, developed by PhD. Brevis, Wherner _ University
%of karlsruhe


% save test ima corrcut sigma tl A B


%sigma: Representative radius
%%%% A, B from thesis of Carlos Estrada, Texas A&M University
%%%A,B=1 normal gaussian distribution
%%%A;B=0.5 the particle is represented by a few pixels, most of the area
%%%have low intensities.
%%%A,B=2; High illuminated particles
%%%A=0.5, B=1 or A=1,B=0.5. In case of optical distorsion, lead with
%%%elliptical shapes instead of circular ones.


% this makes a Gaussian Kermel in a Matrix called 'gm'
n=(1.5*sigma);
c=round(n/2);
n=2*c+1;
c=ceil(n/2);
for i=1:n
	for j=1:n
		x(i,j)=i;
		y(i,j)=j;
	end
end
gm=exp(-(((x-c).^2)/A^2+((y-c).^2))/B^2/(2*sigma));

%Get the image dimensions
dim=size(ima);
nrow=dim(1);
ncol=dim(2);

%Makes extended Matrix
base=zeros(nrow+2*(n-1)/2,ncol+2*(n-1)/2);
base(1+(n-1)/2:nrow+(n-1)/2,1+(n-1)/2:ncol+(n-1)/2)=ima;
dim=size(base);
nrow=dim(1);
ncol=dim(2);
% Converting image to BW %%%%%%%%%
posone=find(base>tl);
basebw=zeros(nrow,ncol);
basebw(posone)=1;

%%%%%%%%%%%%%%%%
[i,j]=ind2sub(dim,posone);

% Se determinan particulas por correlaci??n %

[R]=partcorr(base,gm,n,i,j);%Determination of the correlation plane over corrcut, to fix correlation filter


%Cleaning NaN values %
posnan=isnan(R);
pos2del=find(posnan==1);
R(pos2del)=[];
i(pos2del)=[];
j(pos2del)=[];


%Correlation filter %
posrout=find(abs(R)<=corrcut);
i(posrout)=[];
j(posrout)=[];
[i1,j1]=maxindomain(i,j,dim,base,sigma);           % Filtering peaks that are close each other


%Second time to delete outliers 
[i,j]=maxindomain(i1,j1,dim,base,sigma); % Filtering peaks that are close each other

[i,j]=spaccu(base,n,i,j);

%Coordenates in the c image
i=i-(n-1)/2;
j=j-(n-1)/2;


