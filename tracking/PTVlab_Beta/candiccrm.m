function [canpos,probis,l,maxprob,maxpos,row1b,col1b]=candiccrm(row1,column1,row2,column2,mincandi)

% Algorithm made by PhD Wernher Brevis
% Modify for this interface by MSc Antoine Patalano (2012)
try
    handles=guihandles(getappdata(0,'hgui'));
catch
end

for i=1:length(row1)
    try
          set(handles.progress, 'string' , ['Frame progress: ' int2str(i/length(row1)*100) '% p:1']);drawnow;
      catch
          fprintf('.');
    end
        r=sqrt((row2-row1(i)).^2+(column2-column1(i)).^2);
        [r2,index]=sort(r);
        l(i)=round(r2(mincandi));
        pos=index(1:mincandi);
        
        
        row1b(i)=row1(i);
        col1b(i)=column1(i);
        canpos(i).data(:,1)=row2(pos);
		canpos(i).data(:,2)=column2(pos);
        canpos(i).data(:,3)=row2(pos)-row1(i);
        canpos(i).data(:,4)=column2(pos)-column1(i);
        sizecanpos=size(canpos(i).data);    
        canpos(i).data(:,5)=1/(sizecanpos(1)+1);    %Pij
        probis(i)=1/(sizecanpos(1)+1);     %Pi*
        maxprob(i)=1/(sizecanpos(1)+1);
        maxpos(i)=1;
        

end