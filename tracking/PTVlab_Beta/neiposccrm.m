function [row1,column1,posvecnei]=neiposccrm(row1,column1,tn)
%function [row1,column1,posvecnei,canpos,probis,l,maxprob,maxpos,pos2del]=neiposccrm(row1,column1,tn,canpos,probis,l,maxprob,maxpos)

totpart=length(row1);
%%%%%%%%%%%%% Determining the neighborhood %%%%%%%%%%%%%%%%%%%%%
pos2del=0;
counter=0;
for i=1:totpart               
        row0=row1(i);
		column0=column1(i);
        r=sqrt((row1-row0).^2+(column1-column0).^2);
		pos=find(r<(tn));
        posdel=find(pos==i);
        pos(posdel)=[]; 
        posvecnei(i).data(:,1)=pos;
       
end   
     