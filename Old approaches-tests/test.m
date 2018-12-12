clear;
close all;
true_labels = importdata('labels.txt');
I = imread('imagedata/train_0001.png');
N = size(true_labels,1);
edge_count = size(true_labels, 1);
label_values = size(true_labels, 1);

mat_edges = zeros(1200, 61);
vec_edges = ones(1200, 1);

for k = 1:N
    I = imread(sprintf('imagedata/train_%04d.png', k));
    J = medfilt2(I, [7 7], 'symmetric');
    h = fspecial('average');
    A = imfilter(J, h, 'replicate');
    
    %Find suitable threshold value
    T = graythresh(I);
    %BW = I > T*255;
    BW = imbinarize(A, T);
    
    
    
    %Fill the holes in each black circle, by majority of nbr values
    BW = bwmorph(BW, 'clean');

    %Labeling of a binary image. Neighborhood can be 4 or 8 in 2D.
    %Used inverse of my binary image otherwise it labeled the background
    Ilabel=bwlabel(~BW,8); 

    %Get properties of all objects in the image
    objectProps = regionprops(Ilabel, I, 'BoundingBox');
    objectCount = size(objectProps, 1);

    %Get area for each object
    objectBoundingBox = [objectProps.BoundingBox];
    
    bBox = [objectBoundingBox(1) objectBoundingBox(2) 
            objectBoundingBox(3)  objectBoundingBox(4) ];
    %A = A(bBox(2):bBox(2)+bBox(3), bBox(2):bBox(2)+bBox(4), :);
    
    ax1 = subplot(1,2,1);
    imshow(A);
    ax2 = subplot(1,2,2);
    imshow(Ilabel);
    
    %Get value for each label
    partial_str = strcat(mat2str(true_labels(k,1)), mat2str(true_labels(k,2)));
    label_value = str2double(strcat(partial_str, mat2str(true_labels(k,3))));
    label_values(k) = label_value;
    
    %disp(count_edge_pixels);
    %imshowpair(A,BW,'montage')
    pause(10);
end

%feature: classes edge count
classes_edge_count = mat_edges(any(mat_edges,2),:);

%BW = edge(A,'Canny');
%count_edge_pixels = nnz(BW);
%edge_count(k) = count_edge_pixels;

classes = unique(label_values);
nn=histc(label_values,unique(label_values));
max_count_classes = max(nn);



