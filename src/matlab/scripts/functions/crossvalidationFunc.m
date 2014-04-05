%% Cross Validation
%{
author: Tim Campbell
date: 3/3/2014
This script directly follows load training.m The purpose of loadtraining is
to put all of the training data together. This script prepares the data for
machine learning and then executes cross validation
%}

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

%sub-sample excess noise elements
if diff > 0
    %get a randomized vector of noise indicies
    I = find(training.numlabels == noise);
    I = I(randperm(length(I)),:);
    I = I(1:floor(diff),:);
    %remove those indicies
    training.features(I,:)  = [];
    training.numlabels(I,:) = [];
    training.labels(I,:)    = [];
end

clear diff I noise TF M N uniq classes

%% randomize the data
training = randomizedata(training);

%% cross validation algorithm  
folds = 10;
temp = struct();
foldacc = zeros(folds,1);
predicted = cell(1,folds);

for j = 1:folds
    %building label cross validation
    [temp.train.labels, temp.validate.labels] = ...
        buildcross(training.random.numlabels,j,folds);

    %building feature cross validation
    [temp.train.features, temp.validate.features] = ...
        buildcross(training.random.features,j,folds);

    %make the feature vectors sparse
    temp.train.features = sparse(temp.train.features);
    temp.validate.features = sparse(temp.validate.features);
          disp('made it!');
    %train and test
    svm = train(temp.train.labels,temp.train.features);
          
    [label, acc, ~] = ...
        predict(temp.validate.labels,temp.validate.features,svm,'-q');
    predicted{j} = struct('labels', label, 'accuracy', acc);
    foldacc(j) = acc(1);
    
    %confusion matrix
    [C,order] = confusionmat(temp.validate.labels,label);
    %scale confusion matrix into row by row percentage
    C = (C./repmat(sum(C,2),1,size(C,2)))*100; 
    predicted{j}.confusion = ...
        struct('matrix', C, 'order', order);
end

disp(foldacc());

clear C i j label order temp 

%% Question 2: plot confusion matrix
% need to fix the number of subplots
colormap(flipud(gray))
for i = 1:folds;
    subplot(4,4,i)
    imagesc(predicted{i}.confusion.matrix)
    
    %format axis
    set(gca,'XTick',1:10,...                         
        'XTickLabel', predicted{1}.confusion.order,...  
        'YTick',1:10,...
        'YTickLabel',predicted{1}.confusion.order,...
        'TickLength',[0 0]);
   
    %print title
    title(sprintf('Training size: %g', foldacc(i,1)),... 
        'FontWeight','bold')

end

subplot(4,4,folds+1)
colorbar()
set(gcf, 'color', 'w');
    
