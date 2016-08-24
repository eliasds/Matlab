function [R]=partcorr(base,gm,n,i,j)
%function, developed by PhD. Brevis, Wherner _ University
%of karlsruhe Se recorre la matriz pixel por pixel y se calcula 
%correlacion para determinar particulas
for k=1:length(i)	    
		submatrix=base(i(k)-(n-1)/2:i(k)+(n-1)/2,j(k)-(n-1)/2:j(k)+(n-1)/2);
		max_element=max(max(submatrix));
		submatrix=submatrix./max_element;

		R(k)=corr2(submatrix,gm);

end


		
		
