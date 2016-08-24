function [validresult]=filterrm(colreal,rowreal,vcol,vrow,posvecnei,tqf,percent,minprob,probis,maxprob,minneifrm)
validresult=[];
totpart=length(rowreal);
count1=0;
minneifrm=str2double(minneifrm);
for i=1:totpart
                numberofnei=size(posvecnei(i).data);
          if numberofnei(1) > minneifrm                            
                        a=[vcol(i) vrow(i)];
                        
                            for j=1:numberofnei(1)
                                b=[vcol(posvecnei(i).data(j,1)) vrow(posvecnei(i).data(j,1))];
                                r(j)=norm(a-b);
                            end
                            
                        maxdiff=tqf/100*sqrt(vcol(i)^2+vrow(i)^2);     
                        pos=find(r<=maxdiff);
                        ratio=(length(pos)/numberofnei(1))*100;
                        
                        
                            if (ratio>=percent) 
                                    if (maxprob(i)>=minprob/100) 
                                        if (maxprob(i)>probis(i))
                                                count1=count1+1;
                                                validresult(count1)=i;
                                        end
                                    end
                                                    
                            end
                       
                clear r                
          end     
                
end


if length(validresult)==0
    display('The output of the RM filter is empty');
    text(50,50,'The RM failed, try to use different parameters (ie: radius of neighborhood)','color','r','fontsize',8, 'BackgroundColor', 'k')
end



