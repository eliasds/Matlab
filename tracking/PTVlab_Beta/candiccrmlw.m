function [canpos,probis,maxprob,maxpos,row1b,col1b]=candiccrmlw(row1,column1,row2,column2,lw)
% Algorithm made by PhD Wernher Brevis
% Modify for this interface by MSc Antoine Patalano (2012)

try
    handles=guihandles(getappdata(0,'hgui'));
catch
end
count=0;
for i=1:length(row1)
        try
              set(handles.progress, 'string' , ['Frame progress: ' int2str(i/length(row1)*100) '% p:1']);drawnow;
          catch
              fprintf('.');
        end
        
        r=sqrt((row2-row1(i)).^2+(column2-column1(i)).^2);
        pos=find(r<lw);
        %pos2del=find(pos==i);
        %pos(pos2del)=[];
        
        if length(pos)~=0
        count=count+1;
        row1b(count)=row1(i);
        col1b(count)=column1(i);
        canpos(count).data(:,1)=row2(pos);
		canpos(count).data(:,2)=column2(pos);
        canpos(count).data(:,3)=row2(pos)-row1(i);
        canpos(count).data(:,4)=column2(pos)-column1(i);
        sizecanpos=size(canpos(count).data);    
        canpos(count).data(:,5)=1/(sizecanpos(1)+1);    %Pij
        probis(count)=1/(sizecanpos(1)+1);     %Pi*
        maxprob(count)=1/(sizecanpos(1)+1);
        maxpos(count)=1;
        end
        clear pos r

end