%% load all training data 
% cd ../Research/fabsense/src/matlab/scripts/

%files to load:
%loadnums = [14,15,16,17,18,19];
%loadnums = [5,6,7,8,9,10,11,14,15,16,17,18,19];
trainfolder = '../../../data/train-classifier/';

%prep structures:
train.labels   = [];
train.features = [];

for i = 1:length(loadnums)
    filename = [trainfolder num2str(loadnums(i)) '-train.mat'];
    load(filename);
    train.labels   = [train.labels; training.labels];
    train.features = [train.features; training.features];
end



clear training i unique 
