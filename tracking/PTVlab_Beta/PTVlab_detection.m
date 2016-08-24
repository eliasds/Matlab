function [out,coordi,coordj] = PTVlab_detection (in,roirect,submean,gaussdetecmark,corrthreval,sigmasize,intthreval,meanimg,maskiererx,maskierery,dynadetecmark);%'function made by antoine 09/04/2012
if size(in,3)>1
    in(:,:,2:end)=[];
end
%this function preprocesses the images
if numel(roirect)>0
    x=roirect(1);
    y=roirect(2);
    width=roirect(3);
    height=roirect(4);
else
    x=1;
    y=1;
    width=size(in,2)-1;
    height=size(in,1)-1;
end
%roi (x,y,width,height)
in_roi=in(y:y+height,x:x+width);
if submean == 1
    %Subtract mean of all images selected in order to remove the
    %background of each image. It improves results of PTV
    %added by antoine 06/04/2012    
    
    in_roi=double(in_roi)-meanimg(y:y+height,x:x+width);  

end

if gaussdetecmark ==1    
% code below made PhD. Brevis, Wherner _ University
%of karlsruhe. It makes a Gaussian Kernel
% in case of round particles. A and B can be changed of particles are
%it can be implemented in the GUI in the future
% elyptic 
    lA=1;
    lB=1;        
    [coordi,coordj]=gaussdetection(in_roi,corrthreval,sigmasize,intthreval,lA,lB);    
% elseif gaussdetecmark ==0  
%     [coordi,coordj]=[0,0]; % change here in case of another algorithm
end 


if dynadetecmark ==1    
% code below made PhD. Brevis, Wherner _ University
%of karlsruhe. It makes a Gaussian Kernel
% in case of round particles. A and B can be changed of particles are
%it can be implemented in the GUI in the future
% elyptic 
t_base=1;
c_t=10;
ask=1;
    [coordi,coordj]=dynadetection(in_roi,t_base,c_t,ask);    

end 

%remove particles inside the mask
for i=1:size(maskiererx,1)
    if isempty(maskiererx{i,1})==0
        if isempty(roirect)==0
            p=[coordj+roirect(1);coordi+roirect(2)]';
        else
            p=[coordj;coordi]';
        end
        
        node=[maskiererx{i,1} maskierery{i,1}];
        n      = size(node,1);
        cnect  = [(1:n-1)' (2:n)'; n 1];
        inside=inpoly(p,node,cnect);
        coordj(inside==1)=nan;
        coordi(inside==1)=nan;
    end
end
coordi=coordi-1;
coordj=coordj-1;
out=in;
out(y:y+height,x:x+width)=in_roi;
out=uint8(out);
