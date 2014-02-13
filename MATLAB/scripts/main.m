%% main.m
%{  
Created:    2/3/2014
Author:     Tim Campbell 
Decription: this script is intended to contain the primary structure and 
    data handling for data output from the Ring GINA for the Fabsense
    project.
 
Pipeline:
    import data and create a data structure
    perform basic signal processing (RMS, peaks, etc.)

To Do:
    clean up 
    perform basic signal processing (RMS, peaks, etc.)
    import and view canonical examples
    perform dtw
    add the results to the bins
    machine learning

%}
%% 
clear all; close all;

%% import data and reformat
filename = 'data/hammer_data1/testrun.csv';
%filename = '../Data Recording //data/1/hammer-15';
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
clear s ax i j inc filename

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
bins    = ceil(diff/winSize);

%reformat time to 0 start
d.time(:,2) = d.time - d.time(1);
%build windows bins
d.windows   = (0:winSize:diff)';
%bin the data, returns bincount and indexes
[d.windows(:,2),d.time(:,3)] ...
     = histc(d.time(:,2),d.windows);

%locate the indicies
for i = 1:bins
    if (d.windows(i,2) ~= 0)
        %find the start index in time
        d.windows(i,3) = find(d.time(:,3) == i,1,'first');
        %find the end index in time
        d.windows(i,4) = find(d.time(:,3) == i,1,'last');
    end
end

clear winSize start diff i

%% build feauture vector and labels
d.features = [];
d.featurenames = {};
d.labels = {};

%% import annotations
d.ann.times = load('data/hammer_data1/annotations.csv');
a = importdata('data/hammer_data1/annotations.csv',',');
d.ann.times = a.data ./ 1000;

for i = 1:length(d.ann.times);
    start  = d.ann.times(i,1);
    finish = d.ann.times(i,2);
    sindex = find(d.time >= start,1,'first');
    findex = find(d.time >= finish,1,'first');
    d.ann.examples{i,1} = d.all(sindex:findex,1:10);
end

clear start finish i sindex findex

%% build the rms signal 
%{
for each signal acc, gyr, and mag, we take the x,y, and z values at each
point and find the magnitude, which is the root sum of the squares. In this
case we use rms since the value of n is always 3.
%}
s = {'acc','gyr','mag'};
ax = {'x','y','z'};
tmp = zeros(1,3);

%loop through each sensor, then each timestamp, then each axis
for i = 1:numel(s)
    for j = 1:length(d.time)
        for k = 1:numel(ax)
            %temp is all thres axes at one time
            tmp(k) = d.(s{i}).(ax{k})(j);
        end
        %here's where the magic happens
        d.(s{i}).rms(j,1) = rms(tmp);
    end   
end

clear i j k tmp
