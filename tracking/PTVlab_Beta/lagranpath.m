function TrackID=lagranpath(resultslistptv)
handles=gethand;
numID=max(cell2mat(resultslistptv(6,end)));%gives the number of ID
for i=1:numID
    IndexID=[];
    rowID=[];
    colID=[];
    for frame=1:size(resultslistptv,2)
%         if length(resultslistptv(:,frame))>6 && isempty(cell2mat(resultslistptv(7,frame)))~=1%if vector filtered
%             typevector=cell2mat(resultslistptv(9,frame));
%         else
%             typevector=cell2mat(resultslistptv(5,frame));
%         end
%         instresultptv=cell2mat(resultslistptv(6,frame));
%         
%         
%         ExistID=find(instresultptv(typevector==1)==i);
                ExistID=find(cell2mat(resultslistptv(6,frame))==i);
        
        if isempty(ExistID)==0
            %                         IndexID(frame)=ExistID;
            row=cell2mat(resultslistptv(1,frame));
            rowID=[rowID row(ExistID)];
            col=cell2mat(resultslistptv(2,frame));
            colID=[colID col(ExistID)];
        else
            frame=size(resultslistptv,2);%stop the loop once the ID dispapear
        end
        
    end
    TrackID(i,1).row=rowID;
    TrackID(i,1).col=colID;
    set(handles.plottrajectories, 'string' , ['Total progress: ' int2str((i)/numID*100) '%'])
    drawnow
end
set(handles.plottrajectories, 'string' , 'Plot Trajectories' )


function handles=gethand
hgui=getappdata(0,'hgui');
handles=guihandles(hgui);



 