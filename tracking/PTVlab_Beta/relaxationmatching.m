function [canpos,probis,maxprob,maxpos,ask,workpos]=relaxationmatching(workpos,posvecnei,canpos,epsilon,probis,tq,maxprob,maxpos)

ask=0;
pos2del=0;
conv=0;
for i=1:length(workpos)          % Particles i counter

    sizecan_i=size(canpos(workpos(i)).data);     %number of candidates asociated to i
    
    for j=1:sizecan_i(1)
              
                sizenei_i=size(posvecnei(workpos(i)).data);
                for k=1:sizenei_i(1)
                    
                    candi=posvecnei(workpos(i)).data(k,1);
                    
                    dij=[canpos(workpos(i)).data(j,4) canpos(workpos(i)).data(j,3)];
                    dklp=[canpos(candi).data(:,4) canpos(candi).data(:,3)];
                    
                    r=sqrt((dij(:,1)-dklp(:,1)).^2+(dij(:,2)-dklp(:,2)).^2);
                    pos=find(r<=tq);
                    sum_pl(k)=sum(canpos(candi).data(pos,5));    % Sum over l
                end
                
                Qij=sum(sum_pl);     % Sum over k
                
                Pij_tilde(j)=0.3*canpos(workpos(i)).data(j,5)+4.0*Qij;
         
    end
    %%%% Normalizating probabilities %%%%%%%%
 
                suma=sum(Pij_tilde)+probis(workpos(i));
                canpos(workpos(i)).data(:,5)=Pij_tilde(:)/suma;
                probis(workpos(i))=probis(workpos(i))/suma;
                
                %storing previous values to compare with new ones
                maxprobpre=maxprob(workpos(i));
                maxpospre=maxpos(workpos(i));
                
                %new max values
                maxprob_tilde=max(canpos(workpos(i)).data(:,5));  % Maximum Probability for the particle
                maxprob(workpos(i))=maxprob_tilde(1);
                maxpos_tilde=find(canpos(workpos(i)).data(:,5)==maxprob(workpos(i)));   % Position of the maximum probability
                maxpos(workpos(i))=maxpos_tilde(1); 
               
                
                if abs(maxprob(workpos(i))-maxprobpre)<=epsilon
                    if maxpos(workpos(i))==maxpospre
                        conv=conv+1;
                        pos2del(conv)=i;
                    end
                end
                
                 Pij_tilde=[];
                 r=[];
                 pos=[];
                 sum_pl=[];
end                           
    



if pos2del~=0
    workpos(pos2del)=[];
end

check=size(workpos);

if check(2)==0
    ask=1;
end

               
