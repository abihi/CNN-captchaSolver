function S = myclassifier(im, CNN)

%Denoise each image - median & blur filter
J = medfilt2(im, [7 7], 'symmetric');
h = fspecial('average', [5 5]);
A = imfilter(J, h, 'replicate');
    
%Bounding box: x y height width
bBox = [100 60 100 160];
A = A(bBox(2):bBox(2)+bBox(3), bBox(2):bBox(2)+bBox(4), :);
%Resize image to 28x28
A = aspect_resize(A, 28, 28, 255);
%Removes some small leftover noise
threshold = 190;
A(A<threshold) = 0;
A(A>threshold) = 255;
%Binarize final image then convert to uint8
img = uint8(imbinarize(A));

%classify the image and then convert categorical value to char array
prediction = CNN.CountLabel(double(classify(CNN.finalAhmedNet,img)),1);
prediction = char(cellstr(prediction{1,1}));

%Change prediction from char array to 1x3 vector 
S = [str2double(prediction(1)),str2double(prediction(2)), ...
     str2double(prediction(3))];
S(S == 3) = 0;

end

