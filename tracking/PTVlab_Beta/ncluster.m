function [idx] = ncluster(x,y,radius)
%NCLSUTER Making cluster of neighbors points (2D) lying inside a circle defided
%by a radius

%   Copyright, Antoine Patalano Jun 26, 2012
%   antoine.patalano@gmail.com

%   INPUT:
%   x and y data: a cell in the form xydata = {XvaluesOfCoordinates YvaluesOfCoordinates}.
%   radius: radius of neighborhood/cluster
%   
%   OUTPUT:
%   idx: index of the cluster

%%

idx=zeros(length(x),1);
k=1;
while(~any(idx==0)==0)
    try
        dist = sqrt((x-x(find(idx==0,1))).^2 + (y-y(find(idx==0,1))).^2);
        
        if ~any(idx(dist <= radius)~=0)==0 %Si hay por los menos un punto ya asignado dentro los vecinos
            n=idx(dist <= radius); %n el numero de asignación de cada particula vecinas
            k=n(find(n~=0,1));% eligir la asignación de la primera vecina asignada
            N=find(n~=0);%index de las particulas ya asigadas
            
            for j=1:length(n(n~=0))
                idx(idx==n(N(j)))=k;
            end
        end
        idx(dist <= radius)=k;
%         scatter(x,y,[],idx)
%         axis equal
        k=max(idx)+1;
    catch
    end
end







    





