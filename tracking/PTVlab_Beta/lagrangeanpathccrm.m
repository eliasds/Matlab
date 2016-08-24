function [dis_result]=lagrangeanpathccrm(dis_result,prev_dis_result,roirect)

%% use this function to track an particle with it's ID But ahve to add a
%% new column to dis_result and prev_dis_result . Maybe a 6th coulmn ????
MAXID=retr('MAXID');
maxID=max(prev_dis_result(:,6));

if maxID<MAXID
    maxID=MAXID;
end
MAXID=maxID;
sizedis=size(dis_result,1);

counter=0;
 for i=1:sizedis
     if isempty(roirect)==1
         posrow=find( fix((prev_dis_result(:,3))*1000)/1000==(fix(dis_result(i,1)*1000)/1000));
         %     poscol=find(prev_dis_result(posrow,4)-roirect(1)==dis_result(i,2));
         poscol=find(fix((prev_dis_result(posrow,4))*1000)/1000==(fix(dis_result(i,2)*1000)/1000));
     else
         %     posrow=find(prev_dis_result(:,3)-roirect(2)==dis_result(i,1));
         posrow=find( fix((prev_dis_result(:,3)-roirect(2))*1000)/1000==(fix(dis_result(i,1)*1000)/1000));
         %     poscol=find(prev_dis_result(posrow,4)-roirect(1)==dis_result(i,2));
         poscol=find(fix((prev_dis_result(posrow,4)-roirect(1))*1000)/1000==(fix(dis_result(i,2)*1000)/1000));
     end
    
    %%% In case of a new particle a new ID is create
    if length(poscol)==0
        counter=counter+1;
        dis_result(i,6)=maxID+counter;
    end
    
    %%% In case of the same particle the ID is keeped
    if length(poscol)~=0
        dis_result(i,6)=prev_dis_result(posrow(poscol(1)),6);
    end
end

put('MAXID',MAXID);

function put(name, what)
hgui=getappdata(0,'hgui');
setappdata(hgui, name, what);
 
function var = retr(name)
hgui=getappdata(0,'hgui');
var=getappdata(hgui, name);
    