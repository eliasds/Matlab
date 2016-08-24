function [workpos,canpos,probis,maxprob,maxpos,validposcc]=filtercc(row1,col1,row2,col2,canpos,posvecnei,velvector,tqf,percent,probis,maxprob,maxpos,corrcc,correlation)
% Algorithm made by PhD Wernher Brevis
% Modify for this interface by MSc Antoine Patalano (2012)

try
    handles=guihandles(getappdata(0,'hgui'));
catch
end
workpos=[];
totpart=length(row1);
count2=0;
countvalid=0;
validposcc=[];

for i=1:totpart
        try
              set(handles.progress, 'string' , ['Frame progress: ' int2str(i/totpart*100) '% p:3']);drawnow;
          catch
              fprintf('.');
        end
              if size(posvecnei(i).data,1)==0
                                    countvalid=countvalid+1;
                                                                    
                                    canpos(i).data=[];
                                    canpos(i).data(1,1)=row2(i);
                                    canpos(i).data(1,2)=col2(i);
                                    canpos(i).data(1,3)=row2(i)-row1(i);
                                    canpos(i).data(1,4)=col2(i)-col1(i);
                                    canpos(i).data(1,5)=1;
                                    probis(i)=0;
                                    maxprob(i)=1;
                                    maxpos(i)=1;
                                   
                                    validposcc(countvalid)=i;
              end
              
              if size(posvecnei(i).data,1)~=0
                  
                        a=[velvector(i).data(1) velvector(i).data(2)];
                        numberofnei=size(posvecnei(i).data);
                        
                            for j=1:numberofnei(1)
                                %[i j]
                                b=[velvector(posvecnei(i).data(j,1)).data(1) velvector(posvecnei(i).data(j,1)).data(2)];
                                r(j)=norm(a-b);
                            end
                            
                        maxdiff=tqf/100*sqrt(velvector(i).data(1)^2+velvector(i).data(2)^2);   
                        pos=find(r<=maxdiff);
                        ratio=(length(pos)/numberofnei(1))*100;
                        
                        
                        
                        if (ratio>=percent) & (correlation(i)>corrcc)
                                  %%&%%% Reinicializing variables without future work %%%%%%
                                    countvalid=countvalid+1;
                                                                    
                                    canpos(i).data=[];
                                    canpos(i).data(1,1)=row2(i);
                                    canpos(i).data(1,2)=col2(i);
                                    canpos(i).data(1,3)=row2(i)-row1(i);
                                    canpos(i).data(1,4)=col2(i)-col1(i);
                                    canpos(i).data(1,5)=1;
                                    probis(i)=0;
                                    maxprob(i)=1;
                                    maxpos(i)=1;
                                   
                                    validposcc(countvalid)=i;
                                    
                                 
                        elseif (ratio<percent) | (abs(correlation(i))<corrcc)
                                  count2=count2+1;
                                  workpos(count2)=i;
                          
                        end
                        clear r
             
           
              end   %%%% end for "if size(canpos(i).data,1)~=0"
                
end

