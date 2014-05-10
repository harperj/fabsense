%%
clear all; close all;
cd ~/Documents/Research/fabsense/src/matlab/scripts
addpath functions
dataindex = getDataFolders;
clc

%% 
base = [8,9,10,11,14,15,16,17,18,19];
kevin = 20:34;
molly = [36,38,39,40,41,42,43,44,45,46,47,49,50,51];
claire = [52,53,54,55,56,57,58,59,60,61,62,63];
pablo = [64,65,66,67,68,69];
winsize = .6;
fftbins = 30;

%% Another method is to find the index that matches a search 
trialNums = [base,kevin,molly,claire,pablo];
%trialNums = 23;

for i = 1:length(trialNums)
    ind = find(cell2mat(dataindex(:,2)) == trialNums(i),1,'first');
    prepareDataResample(dataindex{ind,2},dataindex{ind,1},winsize,fftbins);
end
clear i ind

%% example use of trainTest.m 
%(trainNums,testNums,leaveout,featurelist,dataindex)
trainNums  = [base(5:end),kevin,molly,claire,pablo];
testNums   = [base(5:end),kevin,molly,claire,pablo]; 
dataindex  = getDataFolders;
leaveout   = true;
smooth     = true;
%featurelist = (1:18);
featurelist = 1:54;        %false means no special feautres, train all.

%here's the function call
[~, accuracy, predicted,tempCompare] = trainTest(trainNums,testNums,...
    leaveout,featurelist,dataindex,winsize,smooth);

fprintf('\n Whole test was: %5.3f \n \n', ...
        mean(accuracy()*100));
    
%% Obsolete code 
        
%

%% a linear search for an optimum

winsizes = [.2,.4,.6,.8,1,1.5];
fftbins = [5,10,20,30,40,50,60];
leaveoutlist = [true,false];

gridsearch = zeros(length(winsizes),length(fftbins),2);

for i = 2:length(winsizes);
    for j = 1:length(fftbins);
        
        trialNums = [base,kevin,molly,claire,pablo];
        
        for l = 1:length(trialNums)
            ind = find(cell2mat(dataindex(:,2)) == trialNums(l),1,'first');
            prepareDataResample(dataindex{ind,2},...
                dataindex{ind,1},winsizes(i),fftbins(j));
        end
        
        for k  = 1:2;
            trainNums  = [base(5:end),kevin,molly,claire,pablo];
            testNums   = [base(5:end),kevin,molly,claire,pablo];
            dataindex  = getDataFolders;
            leaveout   = leaveoutlist(k);
            smooth     = true;
            winsize = winsizes(i);
            %featurelist = (1:18);
            featurelist = false;        %false means no special feautres, train all.
            
            
            %here's the function call
            [~, accuracy, predicted,tempCompare] = trainTest(trainNums,testNums,...
                leaveout,featurelist,dataindex,winsize,smooth);
            fprintf('\n WindowSize: %2.2f fftBins: %2.0f Leavout: %d \n', ...
                winsizes(i),fftbins(j),leaveoutlist(k));
            fprintf('Whole test was: %5.3f \n \n', ...
                mean(accuracy()*100));
            
            gridsearch(i,j,k) = mean(accuracy()*100);
            fclose('all');
        end
    end
end

    




%% One way to call preProcessFunc is to loop through the dataIndex
%this method doesn't work because the data is kind of broken.
for i = 1:size(dataindex,1)
    fprintf('Attempting to load file: %s \n',dataindex{i,1});
    prepareData(dataindex{i,2},dataindex{i,1},winsize)
end

%%
ind = find(cell2mat(dataindex(:,2)) == 23,1,'first');
trialnum = dataindex{ind,2};
foldername = dataindex{ind,1};
winSize = 0.6;


%% Load test data
testNum = 23;
testfolder = dataindex{find(cell2mat(dataindex(:,2)) == testNum...
    ,1,'first'),1};
% find the test data set and call load data. Returns only the necessary
% parts of the preprocessed data. 
test = loadTest(testNum,testfolder);
clear ind 


%% Train the classifier
trainNums = [5,8,9,10,11,14,15,16,17,18,19];
trainNums = [trainNums, (20:34)];
%testing the effect of adding features
%featurelist = 1:18;
featurelist = false;
[training,classifier,wordLabels] = buildClassifier(trainNums,featurelist);

%% save the classifier
filename = 'classifier.mat';
testfolder = '../../../data/test-classifier/';
filename = [testfolder, filename];
save(filename,'classifier');

%save the word lookup
filename = [testfolder, 'label-lookup'];
save(filename,'wordLabels');

clear filename testfolder wordLabels classifier

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

%% smoothing

predicted.classlabels = zeros(length(predicted.numlabels),4);
numClasses = size(wordLabels,1);

for i  = 1:numClasses
    predicted.classlabels(:,i) = (predicted.numlabels(:,1) == i);
    predicted.classlabels(:,(numClasses+i)) = ...
        conv(predicted.classlabels(:,i),[1,1,1,1,1],'same');
end

[~,I] = max(predicted.classlabels(:,numClasses+1:end),[],2);
predicted.labels(:,2)    = num2class(I,wordLabels);
predicted.numlabels(:,2) = I;

if test.annotations
    compare = [test.labels,predicted.labels(:,2)];
end

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
