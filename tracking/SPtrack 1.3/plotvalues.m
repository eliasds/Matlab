function plotvalues
fid = fopen('x.m','r');
X = fscanf(fid,'%g',[5 1])
fclose(fid) ;

fid = fopen ('y.m','r') ;
Y = fscanf(fid,'%g',[5 1]) ;
fclose(fid) ;

fid = fopen ('time.m','r') ;
T = fscanf(fid,'%g',[5 1]) ;
fclose(fid);

figure,plot(T,X,'--rs','LineWidth',1,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',4)
xlabel('frames or time')
ylabel('x position')
title('Plot of x position vs time')


figure,plot(T,Y,'--rs','LineWidth',1,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',4)
xlabel('frames or time')
ylabel('y position')
title('Plot of y position vs time')            


figure,plot(X,Y,'--rs','LineWidth',1,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',4)
xlabel('x position')
ylabel('y position')
title('position track (x,y)')            
                
adios               