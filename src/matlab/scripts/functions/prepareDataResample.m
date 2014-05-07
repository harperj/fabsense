function prepareDataResample(trialnum,foldername,winSize)
%% a functionized version of preprocess.m
%{
    Created:    4/4/2014
    Author:     Tim Campbell
    Decription: this script is intended to contain the primary structure and
        data handling for data output from the Ring GINA for the Fabsense
        project.

%}

%% import data and reformat
foldername = ['~/Documents/Research/fabsense/data/',foldername, '/'];

trialnum = num2str(trialnum);
filename = [foldername  trialnum '-data.csv'];
%disp(filename)
M = importdata(filename,',',1);

global d;
d = struct('all',M.data);
s = {'acc','gyr','mag'};
ax = {'x','y','z'};

%% fix time
%fix the time oversampling
d.time = fixTiming(M.data(:,1));
disp('that worked!');
%d.time = (M.data(:,1));

%%

%resample the data
fs = 200;
start = d.time(1);
finish = d.time(end);
tq = start:(1/fs):finish;

%%

temp = zeros(length(tq),10);
temp(:,1) = tq;

for i = 2:10
    y = d.all(:,i);
    temp(:,i) = interp1(d.time(:,1),y,tq,'linear');
end



d.all = temp;
d.time = tq';

%% fill the sensor structures with data
inc = 2;
%loop through each sensor then each axis
for i = 1:numel(s)
    %create sensor structures
    d.(num2str(cell2mat(s(i)))) = struct();
    for j = 1:numel(ax)
        %create and fill axes structures
        d.(num2str(cell2mat(s(i))))...
            .(num2str(cell2mat(ax(j)))) = d.all(:,inc);
        inc = inc+1;
    end
end
clear s i j inc filename ind

%% format windows
%{
    This creates indices for windows of length winSize to uniformly divide the
    data for featues. The output is data.windows where column 1 is window in
    time, c. 2 is number of samples in that bin, c. 3 is starting sample index,
    and c. 4 is ending sample index.
%}
%winSize = .25;
difft = finish - start;
buckets = ceil(difft/winSize);

%reformat time to 0 start
d.time(:,2) = d.time - d.time(1);
%build bins
d.bins = (0:winSize:difft)';

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

clear start diff i j k tmp tempStruct s f

%% build feauture vector and labels
d.features = [];
d.featurenames = {};
d.labels = repmat({'noise'},buckets,1);

%% import annotations
filename = [foldername trialnum '-annotations.csv'];
if(exist(filename,'file'))
    a = importdata(filename,',',1);
    d.ann.times  = a.data ./ 1000;
    %throw out the header
    a.textdata(1,:) = [];
    a.textdata = a.textdata(:,1);
    
    d.ann.labels = a.textdata;
    
    for i = 1:size(d.ann.times,1);
        start  = d.ann.times(i,1);
        finish = d.ann.times(i,2);
        sindex = find(d.time >= start,1,'first');
        findex = find(d.time >= finish,1,'first');
        d.ann.examples{i,1} = d.all(sindex:findex,1:10);
    end
    annotations = true;
else
    disp('no annotation file, setting flag and moving on');
    annotations = false;
end

d.annotations = annotations;

clear start finish i sindex findex filename

%% add annotations to labels
%make annotation times 0 sec start point
if annotations
    times = d.ann.times-d.time(1);
    [len,~] = size(d.ann.times);
    
    for i = 1:len
        %this is inclusive time, go me!
        s = find(d.bins(:,1) > times(i,1),1,'first');
        f = find(d.bins(:,1) < times(i,2),1,'last');
        for j = s:f
            d.labels{j} = d.ann.labels{i};
        end
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

%% Build the ratio features
% a super quick and dirty way to get the ratio of 1 to all the others ,
% then 2 to the others less 1, and so on.
k = 1;
for i = 1:8
    for j = i+1:9
        %fprintf('Ratio: %d \\ %d \n',i,j);
        d.features(:,18+k) = d.features(:,i) ./ d.features(:,j);
        k = k+1;
    end
end

clear i j k

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

%this puts and rms signal in the windows.
for i = 1:length(d.windows)
    for j = 1:numel(sen)
        d.windows{i}.(sen{j})(4,:) = ...
            rms(d.windows{i}.(sen{j}),1);
    end
end


%% ahh!! here comes FFT

fftadd = zeros(length(d.windows),24);

for i = 1:length(d.windows)
    
    for j = 1:numel(sen)
        temp = d.windows{i}.(sen{j})(4,:);
        T = winSize;
        NFFT = length(temp);
        fs = NFFT/T;
        df = fs/NFFT;
        fAxis = 0:df:(fs-df);
        F = abs(fft(temp,NFFT));
        %         figure(2)
        %         plot(fAxis(1:floor(end/2)),log(2.*F(1:floor(end/2))),'r')
        
        F = log(2.*F(1:floor(end/2))+0.001);
        fAxis = fAxis(1:floor(end/2));
        
        fftfeatures = zeros(1,8);
        
        edges = [0,1,5,10,20,30,40,50,60];
        
        for k = 1:(length(edges)-1)
            feat = max(F(edges(k) < fAxis & fAxis <= edges(k+1)));
            if k == 1
                if ~size(feat,2)
                    fftfeatures(k) = -5;
                else
                    fftfeatures(k) = F(1);
                end
            elseif ~size(feat,2)
                fftfeatures(k) = -5;
            else
                fftfeatures(k) = feat;
            end
        end
        
        fftadd(i,(j*8-7):(j*8)) = fftfeatures;
        
    end
end

d.features = [d.features,fftadd];

%% save the whole workspace in the directory
filename = [foldername  trialnum '-formatted.mat'];
save(filename,'d')

%% save the training set
trainfolder = '../../../data/training-classifier/';
filename = [trainfolder trialnum '-train.mat'];
training = struct();
training.features = d.features;
training.labels = d.labels;
training.featurenames = d.featurenames;
training.timestamp = d.bins;
training.annotations = annotations;
save(filename,'training');
