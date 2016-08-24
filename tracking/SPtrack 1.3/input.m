function input



fid = fopen('r.m','r');
A = fscanf(fid,'%f');
fclose(fid);
[m,n]= size(A)
S= num2str(A)
for i= 1,m
    tf=isspace('S(i)')
    if tf == 0;
        S(i)= str2num('S(i)')
        S(i) = S(i)
           
    else 
        S(i)= str2num('S(i)')
        S(i)= (S(i-1)+S(i+1))/2
        
    end
      
    
end
diffinput