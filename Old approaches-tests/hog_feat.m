clear;
close all;
I = imread('imagedata/train_0001.png');

J = medfilt2(I, [7 7], 'symmetric');
h = fspecial('average', [5 5]);
A = imfilter(J, h, 'replicate');

%threshold = 200;
%A(A<threshold) = 0;
%A(A>threshold) = 255;

%Bounding box: x y height width
bBox = [100 60 100 160];
A = A(bBox(2):bBox(2)+bBox(3), bBox(2):bBox(2)+bBox(4), :);
%A = aspect_resize(A, 32, 32, 255);

img = mat2gray(A);%imbinarize(A);

test = reshape(img,1, []); 

% Extract HOG features and HOG visualization
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[16 16]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[12 12]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);

% Show the original image
figure; 
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);  
plot(vis2x2); 
title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4); 
title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8); 
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});