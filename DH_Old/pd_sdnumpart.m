numpart=zeros(1,size(E2,2));
for L=1:size(E2,2)
    numpart(L)=size(E2(1,L).time,1);
end
standarddeviation=std(numpart)
%hist(numpart,10)
