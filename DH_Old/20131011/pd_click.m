function [X,Y,Z] = pd_click(E0, z1, z2, numz, lambda, eps, zpad)

skipframes = 10; %number of frames to jump forward/backward
thresh_pix = 10; %how close you need to click to delete a point

figure(98);

z = linspace(z1,z2,numz);
zindex = 1;
danisstillsearching = true;

pos(numz).X = [];
pos(numz).Y = [];
pos(numz).Z = [];

%for j=1:numel(z)
while danisstillsearching
    E1 = fp_fresnelprop(E0,z(zindex), lambda, eps,zpad);
    
    imagesc(abs(E1)); colormap(gray);
    daspect([1 1 1]);
    colorbar;
    title(['Z = ',num2str(z(zindex)),' (',num2str(zindex),'/',...
        num2str(numel(z)),')'],'fontsize',18,'fontweight','bold');
    hold on;
    isactive = true;
    
    %find data from this frame's depth (only occurs if we've seen this
    %frame before)
        %plot(X,Y,'rx');

    xall = [pos.X];
    yall = [pos.Y];
    x = pos(zindex).X;
    y = pos(zindex).Y;
    plot(xall,yall,'rx');
    plot(x,y, 'wo', 'linewidth',1);
        
    while isactive
        
        [xnew,ynew,button] = ginput(1);
        if ~isempty(button)
            %if enter wasn't pressed, do an action
            switch button
                case 1 %left click
                    plot(xnew,ynew,'bo','linewidth',4);
                    plot(xnew,ynew,'wo','linewidth',2);
                    x = [x, xnew];
                    y = [y, ynew];

                 
                    
                case 3 %right click
                    %find the closest particle to the click and remove it
                    d2 = eucdist2([xnew,ynew],[x(:),y(:)]);
                    [mindist,minidx] = min(d2);
                    if mindist<thresh_pix
                        plot(x(minidx),y(minidx),'rx','linewidth',2);
                        x(minidx) = [];
                        y(minidx) = [];
                    end
                    
                    
                case 29 %right arrow
                %next frame
                    zindexnew = min(zindex + 1, numz);
                    isactive = false;
                
                case 28 %left arrow
                %previous frame
                    zindexnew = max(zindex - 1, 1);
                    isactive = false;
                
                case 102 %'f'
                %skip forward XXX frame
                    zindexnew = min(zindex + skipframes, numz);
                    isactive = false;
                
                case 98 %'b'
                %skip backwards XXX frames
                    zindexnew = max(zindex - skipframes, 1);
                    isactive = false;
                
                case 30 %up arrow
                %skip to beginning
                    zindexnew = 1;
                    isactive = false;
                
                case 31 %down arrow
                %skip to end
                    zindexnew = numz;
                    isactive = false;
                
                case 113 %'q'
                    %exit the loop
                    danisstillsearching = false;
                    isactive = false;
            end
        else
            %hit [ENTER]
            isactive = false;
            %zindex = zindex + 1;
        end
    end
    
    hold off;
    
    pos(zindex).X = x;
    pos(zindex).Y = y;
    pos(zindex).Z = ones(size(x))*z(zindex);

    zindex = zindexnew;
    
end

%pull out all of the X,Y,Z values
X = [pos.X];
Y = [pos.Y];
Z = [pos.Z];

%T = abs(E1)<thresh;
%T2 = imerode(T,ones(3,3));
%imdilate
%L = bwlabel(T2);
%R = regionprops(L, 'centroid','area','pixelidxlist','boundingbox');
