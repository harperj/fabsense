function [accuracy,predicted] = trainTest(trainNums,testNums,...
    leaveout,featurelist,dataindex)

% train a single classifier if acceptable
if ~leaveout
    % train
    [~,classifier,wordLabels] = ...
        buildClassifier(trainNums,featurelist);
    
    %and save classifier
    filename = 'classifier.mat';
    testfolder = '../../../data/test-classifier/';
    filename = [testfolder, filename];
    save(filename,'classifier');
    
    %save the word lookup
    filename = [testfolder, 'label-lookup'];
    save(filename,'wordLabels');
else
    
   
end

%% main testing loop
%now comes the main testing loop
for i = 1:length(testNums)
    if leaveout
        %train classifier
        trainNums(find(trainNums == testNums(i))) = [];
        [~,classifier,wordLabels] = ...
            buildClassifier(trainNums,featurelist);
    end
    
    %load the test data
    testfolder = dataindex{find(cell2mat(dataindex(:,2)) == ...
        testNums(i),1,'first'),1};
    
end   


%% Load test data
testNum = 23;
testfolder = dataindex{find(cell2mat(dataindex(:,2)) == testNum...
    ,1,'first'),1};

% find the test data set and call load data. Returns only the necessary
% parts of the preprocessed data. 
test = loadTest(testNum,testfolder);
clear ind 

%% Test the data!

%load the classifier and word labels
load('../../../data/test-classifier/classifier.mat');
load('../../../data/test-classifier/label-lookup.mat');

%make a dummy label vector
dummylabels = ones(size(test.features,1),1) * 10;

%do the testing
test.sparsefeatures = sparse(test.features);
[predicted.numlabels, ~, est] = ...
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
    fprintf('The classification accuracy was: %i \n', ...
        sum(accuracy)/length(accuracy));
    
end

clear i labelsfile dummylabels classifierfile

%% smoothing: performs convolution to remove random labels
predicted = smoothOutput(predicted,wordLabels);

%% meaningful output!
class = predicted.numlabels(1,2);
start = 1;
predicted.output = [];

for i = 2:size(predicted.labels,1)
    c = predicted.numlabels(i,2);
    if c ~= class
        fin = i - 1;
        predicted.output = [predicted.output; [class, start, fin]];
        class = c;
        start = i;
    elseif i == size(predicted.labels,1)
        fin = i;
        predicted.output = [predicted.output; [class, start, fin]];
    end
end

%% test
output = [];

for i = 1:size(predicted.output,1)
    label = num2class(predicted.output(i,1),wordLabels);
    if ~strcmp(label,'noise')
        %crazy lookup to go from output to timestamp to time
        start  = test.time(test.timestamp(predicted.output(i,2),3),1);
        finish = test.time(test.timestamp(predicted.output(i,3),4),1);
        
        %build the final annotation line
        out = {label,start*1000,finish*1000};
        output = [output;out];
    end 
end

T = cell2table(output,'VariableNames',{'label','start','finish'});
filename = ['../../../data/test-classifier/',...
    num2str(testNum),'-classified.csv'];
writetable(T,filename);

filename = ['../../../data/', testfolder, '/', ...
    num2str(testNum),'-classified.csv'];
writetable(T,filename);
