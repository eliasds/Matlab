function result = rollIntoThirdDimension(Mat2D, rows, numz)
z = 1;
for i = 1:rows:numz*rows
    result(:,:,z) = Mat2D( i : (i-1)+rows,:);
    z = z + 1;
end