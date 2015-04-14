function matrix = downsample (matrix, factor)
    %factor is the number of pixels to turn into a subpixel. factor can be
    %a 2 element vector. This function takes factor number of sub pixels
    %and averages them into a single super pixel reducing the size of the
    %image.
    sz = size(matrix) ;
    if length(factor) == 1, factor = [1,1] * factor ; end
    matrix = sum(reshape(matrix, factor(1), []), 1) ; %compact dimension 1
    matrix = reshape(matrix, sz(1)/factor(1), sz(2)) ;
    matrix = reshape(sum(reshape(matrix', factor(2), []), 1),sz(2)/factor(2), sz(1)/factor(1)) ;
    matrix = matrix' / (factor(1) * factor(2)) ;
end