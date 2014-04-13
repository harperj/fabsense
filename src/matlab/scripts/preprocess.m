
%% preprocess.m
%{  
Created:    2/3/2014
Author:     Tim Campbell 
Decription: this script is intended to contain the primary structure and 
    data handling for data output from the Ring GINA for the Fabsense
    project.
 
Pipeline:
    import data and create a data structure
    perform basic signal processing (RMS, peaks, etc.)
    add the results to the bins

To Do:
    clean up 

Done:
    perform dtw - removed
    machine learning - takes place elsewhere
%}
%% 
clear all; close all;
addpath functions

%% import data and reformat
foldername = '../../../data/16-hammer/';
trialnum = num2str(16);
filename = [foldername  trialnum '-data.csv'];
M = importdata(filename,',',1);

global d;
d = struct('all',M.data);
s = {'acc','gyr','mag'};
ax = {'x','y','z'};
d.time = M.data(:,1);
inc = 2;

%loop through each sensor then each axis
for i = 1:numel(s)
    %create sensor structures
    d.(num2str(cell2mat(s(i)))) = struct();
    for j = 1:numel(ax)
        %create and fill axes structures
        d.(num2str(cell2mat(s(i))))...
            .(num2str(cell2mat(ax(j)))) = M.data(:,inc);
        inc = inc+1;
    end 
end
clear s i j inc filename

%% format windows
%{
This creates indices for windows of length winSize to uniformly divide the
data for featues. The output is data.windows where column 1 is window in
time, c. 2 is number of samples in that bin, c. 3 is starting sample index,
and c. 4 is ending sample index. 
%}
winSize = .25;
start   = d.time(1);
diff    = d.time(end) - start;
buckets = ceil(diff/winSize);

%reformat time to 0 start
d.time(:,2) = d.time - d.time(1);
%build bins
d.bins = (0:winSize:diff)';

%bin the data, returns bincount and indexes
[d.bins(:,2),d.time(:,3)] ...
     = histc(d.time(:,2),d.bins);

%locate the indicies
for i = 1:buckets
    if (d.bins(i,2) ~= 0)
        %find the start index in time
        d.bins(i,3) = find(d.time(:,3) == i,1,'first');
        %find the end index in time
        d.bins(i,4) = find(d.time(:,3) == i,1,'last');
    end
end

%remove the 0 bins 
remove = find(d.bins(:,2)==0);
d.bins(remove,:) = [];
buckets = buckets - length(remove);

clear remove

%% build window structures
% places raw data in the d.window{i}.sensor format to be called later for
% windowing and feature building

%build windows, cell array contains split data
d.windows = cell(buckets, 1);

sen = {'acc','gyr','mag'};
ax = {'x','y','z'};
tempStruct = struct('acc',[],'gyr',[],'mag',[]);

for i = 1:buckets
    s = d.bins(i,3);
    f = d.bins(i,4);

    for j = 1:numel(sen)
        %preallocating size of tmp
        tmp = zeros(3,d.bins(i,2));
        for k = 1:numel(ax)
            %temp is all thres axes at one time
           tmp(k,:) = (d.(sen{j}).(ax{k})(s:f))';
        end
        tempStruct.(sen{j})=tmp;
    end   
    d.windows{i} = tempStruct; 
end

clear winSize start diff i j k tmp tempStruct s f 

%% build feauture vector and labels
d.features = [];
d.featurenames = {};
d.labels = repmat({'noise'},buckets,1);

%% import annotations
filename = [foldername trialnum '-annotations.csv'];
if(exist(filename,'file'))
    a = importdata(filename,',');
    d.ann.times  = a.data ./ 1000;
    d.ann.labels = a.textdata;

    for i = 1:size(d.ann.times,1);
        start  = d.ann.times(i,1);
        finish = d.ann.times(i,2);
        sindex = find(d.time >= start,1,'first');
        findex = find(d.time >= finish,1,'first');
        d.ann.examples{i,1} = d.all(sindex:findex,1:10);
    end
else 
    disp('no annotation file, setting flag and moving on');
    no_annot_flag = true;
end

clear start finish i sindex findex filename

%% add annotations to labels 
%make annotation times 0 sec start point
times = d.ann.times-d.time(1);
[len,~] = size(d.ann.times);

for i = 1:len
    s = find(d.bins(:,1) > times(i,1),1,'first');
    f = find(d.bins(:,1) < times(i,2),1,'last');
    for j = s:f
        d.labels{j} = d.ann.labels{i};
    end
end

clear a f s i j times len

%% build rms and variance features
%{
for each signal and axis in each window, we compute the rms and add it to
the feature matrix. Window size is consistent but count of samples varies.
This produces 9 features.
%}
n = 1;

%loop through each window, then each sensor, then each axis
for i = 1:buckets
    %ugh this is horrible programming but whatever. First we do rms
    for j = 1:numel(sen)
        for k = 1:3
           % adds the rms signal of the samples in the window
           d.features(i,n) =...
               rms(abs(d.windows{i}.(sen{j})(k,:)));

           d.features(i,n+1) =...
               var((d.windows{i}.(sen{j})(k,:)));
           
           % this tracks the feature to edit, see featurenames for list
           n = n+1;
        end
    end
    
    %NOW WE DO VARIANCE
    for j = 1:numel(sen)
        for k = 1:3
           % adds the rms signal of the samples in the window
           d.features(i,n) =...
               var((d.windows{i}.(sen{j})(k,:)));
           
           % this tracks the feature to edit, see featurenames for list
           n = n+1;
        end
    end
    n = 1;
end

%this is a cludgy way to add the feature names but it gets the job done
d.featurenames = {'rms-acc-x','rms-acc-y','rms-acc-z'...
    ,'rms-gyr-x','rms-gyr-y','rms-gyr-z'...
    ,'rms-mag-x','rms-mag-y','rms-mag-z'};
          temp = {'var-acc-x','var-acc-y','var-acc-z'...
    ,'var-gyr-x','var-gyr-y','var-gyr-z'...
    ,'var-mag-x','var-mag-y','var-mag-z'};

d.featurenames = [d.featurenames , temp];

clear n i j k temp
%% build the rms signal 
%{
for each signal acc, gyr, and mag, we take the x,y, and z values at each
point and find the magnitude, which is the root sum of the squares. In this
case we use rms since the value of n is always 3.
%}
sen = {'acc','gyr','mag'};
ax = {'x','y','z'};
tmp = zeros(1,3);

%loop through each sensor, then each timestamp, then each axis
for i = 1:numel(sen)
    for j = 1:length(d.time)
        for k = 1:numel(ax)
            %temp is all thres axes at one time
            tmp(k) = d.(sen{i}).(ax{k})(j);
        end
        %here's where the magic happens
        d.(sen{i}).rms(j,1) = rms(tmp);
    end   
end

clear i j k tmp ax

%% save the whole workspace in the directory
filename = [foldername  trialnum '-formatted.mat'];
save(filename,'d')

%% save the training set
trainfolder = '../../../data/train-classifier/';
filename = [trainfolder trialnum '-train.mat'];
training = struct();
training.features = d.features;
training.labels = d.labels;
training.featurenames = d.featurenames;
training.timestamp = d.bins;
save(filename,'training');
