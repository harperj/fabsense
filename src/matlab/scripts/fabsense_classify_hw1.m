%% cross validation algorithm  
folds = 6;
training = train;
clear train

% randomization algorithm
randindex = randperm(length(training.features));
[~,IX] = sort(randindex);
training.random.labels   = training.labels(IX,:);
training.random.features = training.features(IX,:);

%fix the labels to numerical entries
uni = unique(training.random.labels);
training.random.numlabels = zeros(length(training.random.labels),1);

%this is hard coded to the number of unique tools there are
for i = 1:length(training.random.labels)
    if strcmp(training.random.labels{i},uni{1})
        training.random.numlabels(i) = 3;
    elseif strcmp(training.random.labels{i},uni{2})
        training.random.numlabels(i) = 2;
    else
        training.random.numlabels(i) = 1;
    end
end

clear IX i loadnums randindex uni

%%
temp = struct();
foldacc = zeros(folds,1);

for j = 1:folds
    %building label cross validation
    [temp.train.labels, temp.validate.labels] = ...
        buildcross(training.random.numlabels,j);

    %building feature cross validation
    [temp.train.features, temp.validate.features] = ...
        buildcross(training.random.features,j);

    %make the feature vectors sparse
    temp.train.features = sparse(temp.train.features);
    temp.validate.features = sparse(temp.validate.features);
          disp('made it!');
    %train and test
    svm = train(temp.train.labels,temp.train.features);
          
    [~, acc, ~] = ...
        predict(temp.validate.labels,temp.validate.features,svm,'-q');

    foldacc(j) = acc(1);
end

foldacc()
    
