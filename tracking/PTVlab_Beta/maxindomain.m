function [row1,col1]=maxindomain(row,col,dim,base,rd)

count=0;
ask=0;

while ask~=1

        row0=row(1);
		col0=col(1);        

		r=sqrt((row-row0).^2+(col-col0).^2);
   
		pos=find(r<rd);
		possize=size(pos);
                    
        count=count+1;
        ind=sub2ind(dim,row(pos),col(pos));
        
        maximumI=max(base(ind));
        
        posmax=find(base(ind)==maximumI);
      
        row1(count)=row(pos(posmax(1)));
        col1(count)=col(pos(posmax(1)));
        

        row(pos)=[];
        col(pos)=[];

        ind=[];
        
        if length(row)<1
            ask=1;
        end
      
end