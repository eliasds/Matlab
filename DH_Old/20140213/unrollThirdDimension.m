function result = unrollThirdDimension(Mat3D)
[row,col,numz] = size(Mat3D);
result = Mat3D(:,:,1);
for i = 2:numz
    result = [result; Mat3D(:,:,i)];
end