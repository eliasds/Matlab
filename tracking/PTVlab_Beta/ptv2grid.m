function [X Y Usup Vsup InMask] = ptv2grid(x,y,u,v,currentimage,roirect,res,idx,maskiererx,maskierery)
%PTV2GRID Lay down the vectors from PTV on a regular grid

%   Copyright, Antoine Patalano Jul 04, 2012
%   antoine.patalano@gmail.com

%   INPUT:
%   x and y data: a cell in the form xydata = {XvaluesOfCoordinates YvaluesOfCoordinates}.
%   u and v: a cell in the form uvdata= {UvaluesOfCVelocity YvaluesOfVelocity}.
%   currentimage ishould be currentimage=imread(filepath{selected})
%   roirect: region of interest
%   res: size of a element. ex:16 (in pixels)
%   OUTPUT:
%   X and Y: a 2D matrix with X and Y coordinates
%   Usup and Vsup: a 2D matrix with U and V velocities

%%
%define the limit of the ROI
if  isempty(roirect)==1    %
    bordmaxx=size(currentimage,2);
    bordmaxy=size(currentimage,1);
    bordminx=0;
    bordminy=0;
else
    bordmaxx=roirect(3)+roirect(1);
    bordmaxy=roirect(4)+roirect(2);
    bordminx=roirect(1);
    bordminy=roirect(2);
end
%define the grid with the size of the element
xgrid=bordminx:res:bordmaxx;
ygrid=bordminy:res:bordmaxy;


% figure
[X,Y]=meshgrid(xgrid,ygrid);
Usup=nan*X;
Vsup=Usup;
ClustersAsgd=unique(idx);
for i=1:length(ClustersAsgd)
    if length(find(idx==ClustersAsgd(i)))>2 % check if there are more than
        %2 points in one cluster, if not the they won't be interpolated on
        %the grid because you need at least 3 points
        try % for the newest version of MATLAB
        FU=TriScatteredInterp(x(idx==ClustersAsgd(i)),y(idx==ClustersAsgd(i)),u(idx==ClustersAsgd(i)));
        FV=TriScatteredInterp(x(idx==ClustersAsgd(i)),y(idx==ClustersAsgd(i)),v(idx==ClustersAsgd(i)));
        U=FU(X,Y);
        V=FV(X,Y);
        catch    
        U = griddata(x(idx==ClustersAsgd(i)),y(idx==ClustersAsgd(i)),u(idx==ClustersAsgd(i)),X,Y);
        V = griddata(x(idx==ClustersAsgd(i)),y(idx==ClustersAsgd(i)),v(idx==ClustersAsgd(i)),X,Y);
        end
        Usup(isnan(U)==0)=U(isnan(U)==0);% Usup and Vsup are the matrix U and V of each clusters superposed together
        Vsup(isnan(V)==0)=V(isnan(V)==0);
        
    end
end

InMask=Usup*0;
for i=1:size(maskiererx,1)
    if isempty(maskiererx{i,1})==0       
            p=[ reshape(X,size(X,1)*size(X,2),1),reshape(Y,size(Y,1)*size(Y,2),1)];
        % make nan masked value
        node=[maskiererx{i,1} maskierery{i,1}];
        n      = size(node,1);
        cnect  = [(1:n-1)' (2:n)'; n 1];
        inside=inpoly(p,node,cnect);
        
        InMask(inside==1)=1;

    end
end
% InMask=reshape(inside,size(X,1),size(X,2));
        Usup(InMask==1)=nan;
        Vsup(InMask==1)=nan;

% hold on
% quiver(X,Y,Usup,Vsup,'r')


% set(gca,'YDir','reverse')

% pcolor(X,Y,sqrt(Usup.^2+Vsup.^2))
% shading interp;