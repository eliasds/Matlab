%{
function [ out ] = oversample( mode, sampling, x )
%OVERSAMPLE This function will take a set of frequencies and add more
%frequencies. It can then be called x the inverse mode to convert a matrix
%that has been evaluated using those values into a downsampled version

switch mode
    case 'up' %take the vectors and add values
        d1 = diff(x(1:2,1)) ; d2 = diff(x(1,1:2)) ;
        pts = 1:sampling ; pts = pts - mean(pts) ; pts = pts / max(pts) / 2 ;
        [pt_1, pt_2] = ndgrid(pts * d1, pts * d2) ;
        out = zeros(size(x,1), size(x,2) * numel(pt_1)) ;
        for j1=1:length(pts)
            for j2=1:length(pts)
                idx = sub2ind(size(pt_1),j1,j2) - 1 ;
                out(:, size(x,2)*idx + (1:size(x,2))) = x + pt_1(j1,j2) + pt_2(j1,j2) ;
            end
        end
    case 'down' %take the matrix and downsample it
        out = mean(reshape(x,size(x,1),size(x,2)/sampling^2,sampling^2),3) ;
end
end
%}
function [ value ] = oversample( sampling, fx, fy, fn )
%OVERSAMPLE This function will take a set of frequencies and add more
%frequencies. It can then be called x the inverse mode to convert a matrix
%that has been evaluated using those values into a downsampled version

value = zeros(size(fx)) ;
dx = diff(fx(1:2,1)) ; dy = diff(fy(1,1:2)) ;
pts = 1:sampling ; pts = pts - mean(pts) ; pts = pts / max(pts) / 2 ;
[pt_x, pt_y] = ndgrid(pts * dx, pts * dy) ;

for j1=1:length(pts)
    for j2=1:length(pts)
        value = value + fn(fx + pt_x(j1,j2), fy + pt_y(j1,j2)) ;
    end
end
value = value / sampling^2 ;
end