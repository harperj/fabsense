%%
cd ~/Documents/Research/fabsense/src/matlab/scripts
addpath functions
dataindex = getDataFolders;
clc


%% One way to call preProcessFunc is to loop through the dataIndex
for i = 1:size(dataindex,1)
    fprintf('Attempting to load file: %s \n',dataindex{i,1});
    prepareData(dataindex{i,2},dataindex{i,1})
end

%% Another method is to find the index that matches a search 

trialNums = [5,6,7,8,9,10,11,14,15,16,17,18,19];
for i = 1:length(trialNums)
    ind = find(cell2mat(dataindex(:,2)) == trialNums(i),1,'first');
    prepareData(dataindex{ind,2},dataindex{ind,1})
end

clear i ind

%% Train the classifier
trainNums = [5,6,7,10,11,14,15,16,17,18,19];
[training,classifier,wordLabels] = buildClassifier(trainNums);

%% save the classifier
filename = 'classifier.mat';
testfolder = '../../../data/test-classifier/';
filename = [testfolder, filename];
save(filename,'classifier');

%save the word lookup
filename = [testfolder, 'label-lookup'];
save(filename,'wordLabels');

clear filename testfolder wordLabels classifier

%% Load test data
testNum = 8;

% find the test data set and call load data. Returns only the necessary
% parts of the preprocessed data. 
ind = find(cell2mat(dataindex(:,2)) == testNum,1,'first');
test = loadTest(testNum,dataindex{ind,1});
clear ind 

%% Test the data!

%load the classifier and word labels
load('../../../data/test-classifier/classifier.mat');
load('../../../data/test-classifier/label-lookup.mat');

%make a dummy label vector
dummylabels = ones(size(test.features,1),1) * 10;

%do the testing
test.sparsefeatures = sparse(test.features);
[predicted.numlabels, ~, ~] = ...
    predict(dummylabels,test.sparsefeatures,classifier,'-q');

%check with the annotations
if test.annotations
    
    %convert the predicted num labels into strings
    predicted.labels = cell(length(predicted.numlabels),1);
    accuracy = false(length(predicted.labels),1);
    for i = 1:length(predicted.numlabels)
        %returns the name associated with the number
        predicted.labels{i,1} = wordLabels{predicted.numlabels(i),1};
        
        %now check the accuracy
        accuracy(i) = strcmp(test.labels(i),predicted.labels(i));
    end
    
    %now check the accuracy
    
end

clear i wordLabels labelsfile dummylabels classifierfile

%%here's where I left off on saturday night. loadTest needs to be fully
%%written out then the test portion. then, if there's annotations, the
%%accuracy needs to be compared. Finally, a simple output script. 




%{
Ideally I would have a list of trials for training and a list of trials for
testing. You could run this main script on these. 

You could also have a section for cross validation as a function. 

In the user study we will have the classifier built so it will be something
like a list of test trials and the chosen classifier. The annotation will
be optional and the output will be a csv for use in demoCut and accuracy
(if annotations included). 
%}

%% smoothing

predicted.classlabels = zeros(104,4);

predicted.classlabels(:,1) = (predicted.numlabels(:,1) == 1);
predicted.classlabels(:,2) = (predicted.numlabels(:,1) == 2);
predicted.classlabels(:,3) = (predicted.numlabels(:,1) == 3);
predicted.classlabels(:,4) = (predicted.numlabels(:,1) == 4);

predicted.classlabels(:,5) = conv(predicted.classlabels(:,1),[1,1,1],'same');
predicted.classlabels(:,6) = conv(predicted.classlabels(:,2),[1,1,1],'same');
predicted.classlabels(:,7) = conv(predicted.classlabels(:,3),[1,1,1],'same');
predicted.classlabels(:,8) = conv(predicted.classlabels(:,4),[1,1,1],'same');



