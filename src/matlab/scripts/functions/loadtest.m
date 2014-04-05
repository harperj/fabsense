function test = loadtest(num)
%% load all training data 
% cd ../Research/fabsense/src/matlab/scripts/

%files to load:
%loadnums = [14,15,16,17,18,19];
%loadnums = [5,6,7,8,9,10,11,14,15,16,17,18,19];
trainfolder = '../../../data/train-classifier/';

%prep structures:
test.labels   = [];
test.features = [];
test.timestamps = [];

filename = [trainfolder num2str(num) '-train.mat'];
load(filename);
test.labels    = [training.labels];
test.features  = [training.features];
test.timestamp = [training.bins];

clear training i unique 

end