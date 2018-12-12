clear;
close all;

% Load CNN pretrained on MNIST, code in CNNexample.m (source: matlab)
load ahmedNet

true_labels = importdata('labels.txt');
%replace 0's with 3's, so they dont disappear when converted to double
true_labels(true_labels == 0) = 3;

%Create vector containing all labels as double values
labels = size(true_labels, 1);
for k = 1:size(true_labels,1)
    %Vector to string then get double value for each label
    partial_str = strcat(mat2str(true_labels(k,1)), mat2str(true_labels(k,2)));
    label_value = str2double(strcat(partial_str, mat2str(true_labels(k,3))));
    labels(k) = label_value;
end
labels = labels';
labels = categorical(labels);

%Create vector with all image paths (paths are to resized images with noise removed)
training_imagePaths = cell(size(true_labels,1),1);
for k = 1:size(true_labels, 1)
    filename = sprintf('imagedata/train_%04d.png', k);
    fullFileName = fullfile('denoised_imagedata/', filename);
    training_imagePaths(k) = {fullFileName};
end

%Put my image paths and labels in ImageDatastore struct
captchaData = digitData;
captchaData.Files = training_imagePaths;
captchaData.Labels = labels;

%Count classes and occurances of each class
CountLabel = captchaData.countEachLabel;

%Images per class to split into training set, rest to test
trainingNumFiles = 34;
rng(1) % For reproducibility
%Creates 912 training examples and 282 test examples
[trainCaptchaData,testCaptchaData] = splitEachLabel(captchaData, ...
				trainingNumFiles,'randomize'); 

%Modify late layers in CNN to fit my dataset
layers = ahmedNet.Layers;
layers(5) = fullyConnectedLayer(27);
layers(7) = classificationLayer;

%Specified training options - Stochastic gradient descent with minibatch
opts = trainingOptions('sgdm', 'InitialLearnRate', 0.001, 'MaxEpochs', 200, 'MiniBatchSize', 64);

%training of network (trained on NVIDIA 1060 GPU)
myNet = trainNetwork(trainCaptchaData, layers, opts);

%Test the performance of the network - print accuracy
YTest = classify(myNet,testCaptchaData);
TTest = testCaptchaData.Labels;
accuracy = sum(YTest == TTest)/numel(TTest)

%Save trained network
finalAhmedNet = myNet;
save finalAhmedNet
