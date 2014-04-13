function test = loadTest(num,trialname)
%% load all training data 
% cd ../Research/fabsense/src/matlab/scripts/

%files to load:
%loadnums = [14,15,16,17,18,19];
%loadnums = [5,6,7,8,9,10,11,14,15,16,17,18,19];
trainfolder = ['../../../data/' trialname '/'];

%prep structures:
test.labels    = [];
test.features  = [];
test.timestamp = [];

filename = [trainfolder num2str(num) '-formatted.mat'];
if fopen(filename) == -1
    fprintf('File not yet processed. Attempting to preprocess the file \n');
    prepareData(num,trialname);
end

load(filename);

test.labels    = [d.labels];
test.features  = [d.features];
test.timestamp = [d.bins];
test.annotations = [d.annotations];
test.time      = [d.time];

end