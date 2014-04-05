%%
addpath functions
loadnums = [5,6,7,8,9,10,11,14,15,16,17,18,19];

training = loadtraining(loadnums);
svm = crossvalidation(training);

%%
cd ~/Documents/Research/fabsense/src/matlab/scripts
dataindex = getDataFolders;

%% One way to call preProcessFunc is to loop through the dataIndex
for i = 1:size(dataindex,1)
    preprocessFunc(dataindex{i,2},dataindex{i,1})
end

%% Another method is to find the index that matches a search 
trialnum = 5;
ind = find(cell2mat(dataindex(:,2)) == trialnum,1,'first');
preprocessFunc(dataindex{ind,2},dataindex{ind,1})



%% 

%{
Ideally I would have a list of trials for training and a list of trials for
testing. You could run this main script on these. 

You could also have a section for cross validation as a function. 

In the user study we will have the classifier built so it will be something
like a list of test trials and the chosen classifier. The annotation will
be optional and the output will be a csv for use in demoCut and accuracy
(if annotations included). 
%}


