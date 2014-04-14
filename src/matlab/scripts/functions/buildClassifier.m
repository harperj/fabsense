function [training, classifier, labelLookup] = ...
    buildClassifier(trialNums, featurelist)
%{
psuedocode: 
    given trialNums, loadtraining into a single training set
    do the appropriate preprocessing steps:
        remove excess noise
        convert labels to numbers
    train the classifier
    save the classifier

Returns three variables 
    1. training data used to build the classifier
    2. the classifier itself
    3. the unique labels it used to make the numbers

starting folder:
cd ../Research/fabsense/src/matlab/scripts/

Notes:
No error checking to see if the trial number has been processed

%}

%% Load Training Data
%relative file path
trainfolder = '../../../data/train-classifier/';

%prep structures:
training.labels   = [];
training.features = [];

for i = 1:length(trialNums)
    filename = [trainfolder num2str(trialNums(i)) '-train.mat'];
    data = load(filename);
    if data.training.annotations
        training.labels   = [training.labels; data.training.labels];
        training.features = [training.features; data.training.features];
    end
end

clear data
%% convert labels
uniq  = unique(training.labels);
classes = length(uniq);
training.numlabels = zeros(length(training.labels),1);

% converts the labels from strings to numbers, regardless of classes
for i = 1:length(training.labels)
    TF = strcmp(training.labels{i},uniq);
    numlabel = find(TF == 1,1,'first');
    training.numlabels(i) = numlabel;
    
end

% a lookup for later
labelLookup = cell(length(uniq),2);

for i = 1:length(uniq)
    labelLookup{i,1} = uniq{i};
    labelLookup{i,2} = i;
end

clear i numlabel

%% determine the quantity of noise training
% find the noise label:
TF = strcmp('noise',uniq);
noise = find(TF == 1,1,'first');

% take the mean of the other classes
N = hist(training.numlabels,classes);
M = N;
M(noise) = [];

% determine extra samples we have
diff = N(noise) - mean(M);
% 
%sub-sample excess noise elements
% if diff > 0
%     %get a randomized vector of noise indicies
%     I = find(training.numlabels == noise);
%     I = I(randperm(length(I)),:);
%     I = I(1:floor(diff),:);
%     %remove those indicies
%     training.features(I,:)  = [];
%     training.numlabels(I,:) = [];
%     training.labels(I,:)    = [];
% end

clear diff I noise TF M N uniq classes

%% Actually build the classifier
%make the feature vectors sparse
if featurelist == false
    training.sparsefeatures = sparse(training.features);
else
    training.sparsefeatures = sparse(training.features(:,featurelist));
end

%train and test
classifier = train(training.numlabels,training.sparsefeatures);
end

