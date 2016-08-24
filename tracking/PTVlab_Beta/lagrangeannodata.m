function [dis_result]=lagrangeannodata(prev_dis_result,dis_result,mpcc)

% fileout=sprintf(outputfile,nframe-1);
% prev_dis_result=load(fileout);
% 
% maxID=max(prev_dis_result(:,1));
% 
% dis_result(1:mpcc)=[maxID+1:maxID+1+mpcc];


try
maxID=max(prev_dis_result(:,6));
dis_result(1:mpcc,6)=[maxID+1:maxID+1+mpcc];
catch
end



    