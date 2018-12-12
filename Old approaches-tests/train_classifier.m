function classifier = train_classifier(set_size, true_labels, HOG_cell_size)
%TRAIN_CLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

training_labels = size(set_size);
training_features = zeros(set_size, 16261);
edge_count = size(true_labels, 1);

for k = 1:set_size
    I = imread(sprintf('imagedata/train_%04d.png', k));
    
    %Preprocess image, remove noise
    J = medfilt2(I, [7 7], 'symmetric');
    h = fspecial('average', [5 5]);
    A = imfilter(J, h, 'replicate');
    
    %Count edges
    BW = edge(A,'Canny');
    count_edge_pixels = nnz(BW);
    edge_count(k) = count_edge_pixels;
    
    %Bounding box: x y height width
    bBox = [100 60 100 160];
    A = A(bBox(2):bBox(2)+bBox(3), bBox(2):bBox(2)+bBox(4), :);
    %A = aspect_resize(A, 32, 32, 255);
    threshold = 190;
    A(A<threshold) = 0;
    A(A>threshold) = 255;
    img = mat2gray(A);%imbinarize(A);
    
    %Histogram of oriented gradients features
    %training_features(k,:) = extractHOGFeatures(img,'CellSize', HOG_cell_size);
    
    %Small image
    %training_features(k,:) = reshape(img, 1, []);
    
    %fourier features
    training_features(k,:) = reshape(abs(fft2(img)),1,[]);
    
    %Vector to string then get double value for each label
    partial_str = strcat(mat2str(true_labels(k,1)), mat2str(true_labels(k,2)));
    label_value = str2double(strcat(partial_str, mat2str(true_labels(k,3))));
    training_labels(k) = label_value;
end

%classifier training (SVM)
t = templateSVM('Standardize',1,'KernelFunction','gaussian');
classifier = fitcecoc(training_features, training_labels, 'Learners',t);

%classifier training (Binary decision tree)
%classifier = fitctree(training_features, training_labels);

%classifier training (kNN)
%classifier = fitcknn(training_features, training_labels, 'NumNeighbors',27,'Standardize',1);

end

