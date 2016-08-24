function [] = spaceplots(fpad,axpad)
% SPACEPLOTS: Reposition plots in a figure with custom spacing between them
% 
%   Usage: Draw your figure, with all the subplots. Make sure it is the
%   current figure before you call SPACEPLOTS. Function simply repositions
%   axes in a figure, it does not change any other properties of the figure
% 
%   SPACEPLOTS(fpad,axpad) repositions plots to add figure padding and axes
%   padding as specified by fpad and axpad respectively
% 
%   "fpad" is a 4 element vector specifying (in normalized units)
%   the space to be left around the entire subplot grid. The format for
%   figure padding is [left right top bottom]
% 
%   "axpad" is a 2 element vector specifying (in normalized units) the
%   horizontal and vertical padding between the panels of the subplot grid.
%   The format for axes padding is [horizontal vertical]
% 
%   SPACEPLOTS without any input arguments assumes zero figure padding and
%   axes padding
%  
%   version 1.1
%   (c) Aditya Joshi, 2012

u1 = get(gcf,'units');      %to restore later
set(gcf,'units','normalized')

if nargin < 2, axpad = [0 0]; end
if nargin < 1, fpad = [0 0 0 0]; end

fPadLeft = fpad(1); fPadRight = fpad(2);
fPadTop = fpad(3);  fPadBottom = fpad(4);
fBox = [fPadLeft fPadBottom 1-fPadLeft-fPadRight 1-fPadTop-fPadBottom];
axpadH = axpad(1); axpadV = axpad(2);

% Get axes handles. If SubplotGrid is empty, there is only 1 axes
hAxGrid = getappdata(gcf,'SubplotGrid');
if isempty(hAxGrid)
    hAxes = gca;
    oneAxes = 1;
else
    oneAxes = 0;
end

%==========================================================================
% For Single Axes
%==========================================================================
if oneAxes
        
    t = get(hAxes,'TightInset');
    
    InsetLeft = t(1); InsetBottom = t(2);
    InsetRight = t(3); InsetTop = t(4);

    axWidth = 1 - fPadLeft - fPadRight - InsetLeft - InsetRight;
    axHeight = 1 - fPadTop - fPadBottom - InsetTop - InsetBottom;
    
    axPos = [InsetLeft+fPadLeft InsetBottom+fPadBottom axWidth axHeight];
    set(gca,'Position',axPos)
    
    return
end

%==========================================================================
% For Multiple Axes (Subplots)
%==========================================================================

nRows = size(hAxGrid,1);
nCols = size(hAxGrid,2);

defAx = getappdata(gcf,'SubplotDefaultAxesLocation');
fRow = 1/nRows; fCol = 1/nCols;

hAxes = findobj('Parent',gcf,'-and','Type','axes','-and','-not','Tag','legend');

% -------------------------------------------------------------------------
% Information about current figure: For each axes, get the starting row, 
% column and row span, column span
% -------------------------------------------------------------------------

row0 = zeros(size(hAxes)); col0 = zeros(size(hAxes));
rowSpan = zeros(size(hAxes)); colSpan = zeros(size(hAxes));

for i = 1:length(hAxes)
    
    axPos = get(hAxes(i),'Position');
    
    row0(i) = floor(((axPos(2)-defAx(2))/defAx(4))/fRow) + 1;
    col0(i) = floor(((axPos(1)-defAx(1))/defAx(3))/fCol) + 1;
    
    if abs(axPos(4) - defAx(4)) < 0.005
        disp('ccc')
        rowSpan(i) = nRows;
    else
        rowSpan(i) = floor((axPos(4)/defAx(4))/fRow) + 1;
    end
    
    if abs(axPos(3) - defAx(3)) < 0.005
        disp('ddd')
        colSpan(i) = nCols;
    else
        colSpan(i) = floor((axPos(3)/defAx(3))/fCol) + 1;
    end
    
end

% -------------------------------------------------------------------------
% Information about current figure: Define consistent TightInset values for
% axes, so that they line up in the grid
% -------------------------------------------------------------------------

InsetLeft = zeros(nRows,nCols);
InsetRight = zeros(nRows,nCols);
InsetTop = zeros(nRows,nCols);
InsetBottom = zeros(nRows,nCols);

for m = 1:nRows
    
    % bottom inset
    ax = find(row0 == m);
    if isempty(ax)
        InsetBottom(m,:) = 0;
    else
        bpad = zeros(size(ax));
        for i = 1:length(ax)
            t = get(hAxes(ax(i)),'TightInset');
            bpad(i) = t(2);
        end
        InsetBottom(m,:) = max(bpad);
    end
    
    % top inset
    vcomp = row0 + rowSpan - ones(size(row0));
    ax = find(vcomp == m);
    if isempty(ax)
        InsetTop(m,:) = 0;
    else     
        tpad = zeros(size(ax));
        for i = 1:length(ax)
            t = get(hAxes(ax(i)),'TightInset');
            tpad(i) = t(4);
        end
        InsetTop(m,:) = max(tpad);
    end
    
end
        
for n = 1:nCols

    % left inset
    ax = find(col0 == n);
    if isempty(ax)
        InsetLeft(:,n) = 0;
    else
        lpad = zeros(size(ax));
        for i = 1:length(ax)
            t = get(hAxes(ax(i)),'TightInset');
            lpad(i) = t(1);
        end
        InsetLeft(:,n) = max(lpad);
    end

    % right inset
    vcomp = col0 + colSpan - ones(size(col0));
    ax = find(vcomp == n);
    if isempty(ax)
        InsetRight(:,n) = 0;
    else
        rpad = zeros(size(ax));
        for i = 1:length(ax)
            t = get(hAxes(ax(i)),'TightInset');
            rpad(i) = t(3);
        end
        InsetRight(:,n) = max(rpad);
    end

end

% -------------------------------------------------------------------------
% Information about new figure: Define basic grid
% -------------------------------------------------------------------------

GridLeft = zeros(nRows,nCols);
GridBottom = zeros(nRows,nCols);
GridWidth = zeros(nRows,nCols);
GridHeight = zeros(nRows,nCols);

for m = 1:nRows
    for n = 1:nCols
        
        if  m == 1
            GridBottom(m,n) = fBox(2);
            GridHeight(m,n) = (fBox(4)/nRows) - axpadV/2;
        elseif m == nRows
            GridBottom(m,n) = fBox(2) + (m-1)*(fBox(4)/nRows) + axpadV/2;
            GridHeight(m,n) = (fBox(4)/nRows) - axpadV/2;
        else
            GridBottom(m,n) = fBox(2) + (m-1)*(fBox(4)/nRows) + axpadV/2;
            GridHeight(m,n) = (fBox(4)/nRows) - axpadV;
        end
        
        if n == 1
            GridLeft(m,n) = fBox(1);
            GridWidth(m,n) = fBox(3)/nCols - axpadH/2;
        elseif n == nCols
            GridLeft(m,n) = fBox(1) + (n-1)*(fBox(3)/nCols) + axpadH/2;
            GridWidth(m,n) = fBox(3)/nCols - axpadH/2;
        else
            GridLeft(m,n) = fBox(1) + (n-1)*(fBox(3)/nCols) + axpadH/2;
            GridWidth(m,n) = fBox(3)/nCols - axpadH;
        end
        
    end
end

% -------------------------------------------------------------------------
% New figure: Reposition axes
% -------------------------------------------------------------------------

for i = 1:length(hAxes)
    
    r0 = row0(i);
    c0 = col0(i);
    
    r1 = r0 + rowSpan(i) - 1;
    c1 = c0 + colSpan(i) - 1;
    
    axLeft = GridLeft(r0,c0) + InsetLeft(r0,c0);
    axBottom = GridBottom(r0,c0) + InsetBottom(r0,c0);
    
    axHeight = sum(GridHeight(r0:r1,c0)) + axpadV*(rowSpan(i)-1) ...
               - InsetBottom(r0,c0) - InsetTop(r1,c1);
           
    axWidth = sum(GridWidth(r0,c0:c1)) + axpadH*(colSpan(i)-1) ...
               - InsetLeft(r0,c0) - InsetRight(r1,c1);
    
    set(hAxes(i),'Position',[axLeft axBottom axWidth axHeight])
    
    % recalculate SubplotDefaultAxesLocation
    if i == 1
        sdx = [axLeft axLeft+axWidth];
        sdy = [axBottom axBottom+axHeight];
    else
        sdx = [min([sdx(1) axLeft]) max([sdx(2) axLeft+axWidth])];
        sdy = [min([sdy(1) axBottom]) max([sdy(2) axBottom+axHeight])];
    end
    
end

% -------------------------------------------------------------------------
% reset properties
% -------------------------------------------------------------------------

set(gcf,'units',u1)
setappdata(gcf,'SubplotGrid',hAxGrid)
setappdata(gcf,'SubplotDefaultAxesLocation',[sdx(1) sdy(1) sdx(2)-sdx(1) sdy(2)-sdy(1)])