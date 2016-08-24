function [i,j]=spaccu(base,n,i,j)

for k=1:length(i)
       submatrix=base(i(k)-(n-1)/2:i(k)+(n-1)/2,j(k)-(n-1)/2:j(k)+(n-1)/2);
       [l,w,I]=find(submatrix);
       sum_I=sum(I);
       
       ip=sum(l.*I)/sum_I;
       jp=sum(w.*I)/sum_I;       

       i(k)=(i(k)-(n-1)/2)+ip-1;
       j(k)=(j(k)-(n-1)/2)+jp-1;
   
end