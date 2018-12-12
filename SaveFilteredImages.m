clear;

for k = 1:1200
    filename = sprintf('imagedata/train_%04d.png', k);
    I = imread(filename);
    
    %Preprocess image, remove noise
    J = medfilt2(I, [7 7], 'symmetric');
    h = fspecial('average', [5 5]);
    A = imfilter(J, h, 'replicate');
    
    %Bounding box: x y height width
    bBox = [100 60 100 160];
    A = A(bBox(2):bBox(2)+bBox(3), bBox(2):bBox(2)+bBox(4), :);
    A = aspect_resize(A, 28, 28, 255);
    threshold = 190;
    A(A<threshold) = 0;
    A(A>threshold) = 255;
    img = imbinarize(A);
    
    %Save files in new folder
    fullFileName = fullfile('denoised_imagedata/', filename);
    imwrite(img, fullFileName);
end