%% load all training data 
% cd ../Research/fabsense/src/matlab/scripts/
clear all; close all;

%files to load:
loadnums = [5,6,7];
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

t = train;

clear training i train
