function outputImage = aspect_resize(image,x,y,padValue)
%ASPECT_RESIZE Summary of this function goes here
%   Detailed explanation goes here

[rowSize, colSize, ~] = size(image);

diff = abs(rowSize-colSize);
if rowSize > colSize
    paddedImage = padarray(image, [diff/2 0], padValue);
else
    paddedImage = padarray(image, [0 diff/2], padValue);
end

resizedImage = imresize(paddedImage, [x, y]);
outputImage = resizedImage;
end

