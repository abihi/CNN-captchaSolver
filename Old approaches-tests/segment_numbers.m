clear;
close all;

%I = imread('imagedata/train_0001.png');

for k = 1:1200
    I = imread(sprintf('imagedata/train_%04d.png', k));
    
    %Preprocess image, remove noise
    J = medfilt2(I, [7 7], 'symmetric');
    h = fspecial('average', [5 5]);
    A = imfilter(J, h, 'replicate');

    %Creates a threshold T between 0-1
    T = graythresh(A);

    %Create binary image, with threshold T
    bw = imbinarize(A, T);

    %Fill the holes in each black circle, 'majority' sets a pixel 
    bw2 = bwmorph(bw, 'majority');
    bw2(:, 1:1+3) = 255;
    bw2(:, end-3:end) = 255;
    
    %Distance transform, hills changed to valleys
    D = bwdist(bw2);
    %imshow(D,[]);

    %Labeling of a binary image. Neighborhood can be 4 or 8 in 2D.
    %Used inverse of my binary image otherwise it labeled the background
    Ilabel=bwlabel(~bw2,8); 
    coloredLabels = label2rgb(Ilabel, 'spring');
    %imshow(coloredLabels);

    %Get properties of all objects in the image
    objectProps = regionprops(Ilabel, 'BoundingBox');
    objectCount = size(objectProps, 1);
    
    if objectCount == 2
        rect1 = uint8(objectProps(1).BoundingBox);
        rect2 = uint8(objectProps(2).BoundingBox);
        if (rect1(3)*rect1(4)) > (rect2(3)*rect2(4))
            vertCut = uint8(rect1(1)+(rect1(3)/2));
            bw2(:, vertCut-1:vertCut) = 255;
            sliceD = D(rect1(2):rect1(2)+rect1(3), rect1(1):rect1(1)+rect1(4));
            maximum = max(max(sliceD));
            [x,y]=find(sliceD==maximum);
            cutValue = uint8(y(1) + rect1(1));
            %Add vertical line to image
            bw2(:, cutValue) = 255;
        else
            vertCut = uint8(rect2(1)+(rect2(3)/2));
            %bw2(:, vertCut-1:vertCut) = 255;
            sliceD = D(rect2(2):rect2(2)+rect2(3), rect2(1):rect2(1)+rect2(4));
            maximum = max(max(sliceD));
            [x,y]=find(sliceD==maximum);
            cutValue = uint8(y(1) + rect2(1));
            %Add vertical line to image
            bw2(:, cutValue) = 255;
        end
        
        Ilabel = bwlabel(~bw2,8); 
        objectProps = regionprops(Ilabel, 'BoundingBox');
        objectCount = size(objectProps, 1);
    end
    
    if objectCount > 3
        
        %Ilabel = bwlabel(~bw2,8); 
        %objectProps = regionprops(Ilabel, 'BoundingBox');
        %objectCount = size(objectProps, 1);
    end
    
    if objectCount ~= 3
        fprintf('Failed segmentation (objectCount = %d): imagedata/train_%04d.png\n', objectCount, k);
        imshow(bw2);
        for i=1:objectCount
            rect = objectProps(i).BoundingBox;
            hold on
            rectangle('Position', rect,...
            'EdgeColor','g', 'LineWidth', 1)
        end
        pause(3);
    end
    
    %imshow(bw2);
    %for i=1:objectCount
    %    rect = objectProps(i).BoundingBox;
    %    %hold on
    %    rectangle('Position', rect,...
    %    'EdgeColor','g', 'LineWidth', 1)
    %end
    
    %pause(1);
end


