function train = randomizedata(train)
%% randomization algorithm
randindex = randperm(length(train.features));
[~,IX] = sort(randindex);
train.random.labels    = train.labels(IX,:);
train.random.features  = train.features(IX,:);
train.random.numlabels = train.numlabels(IX,:);

clear IX i loadnums randindex uni
end