%%


for i = 1:(floor(length(rms(:,2))/5))
    binsRMS(i) = mean(rms((5*i-4):(5*i),2));
end
%%

%using data from hammer1, binsRMS(:,2), gyro
trainIndex = [243,252;252,261;261,270;269,278;278,287;...
    286,295;295,304;304,313;313,322;322,331;331,340];

%%

hammerExamples = zeros(11,10);

for i = 1:length(trainIndex)
    hammerExamples(i,1:10) = ...
        binsRMS(trainIndex(i,1):trainIndex(i,2),1);
    display(i);
end

%%
badExamples = zeros(10,10);
for i = 1:length(badExamples)
   badExamples(i,1:10) = binsRMS((90+i*10):(99+i*10),1);
end
    
%%
% all testing data
allTest = zeros(430,10);
for i = 1:length(allTest)
    allTest(i,1:10) = binsRMS(i:i+9,1);
end

%%
%allTestLabels = repmat('bad',length(allTest),1);
for i = 1:length(trainIndex)
    allTestLabels(trainIndex(i,1),1:3) = 'ham';
end

%%
nbGaussian = NaiveBayes.fit(allExamples, labels);
classified = nbGaussian.predict(allExamples);

%%
%testing a step through error matching
%using hammer1.mat, run plotRealTime, and then take and
%example from the rms.

example = rms(1519:1561,2);
%example = hamEx;
exLen = length(example);

for i = 1:(length(rms())-exLen)
    step = rms(i:exLen+i-1,2);
    %error(i) = sum(abs(step - example));
    [Dist,D,k,w] = dtw(example',step');
    Distance(i) = Dist;
    
    
end

%scale error to 0 - 1
%error(:) = error()./max(error());

%%
%testing step through DTW
%using hammer1.mat, run plotRealTime, and then take and
%example from the rms.

%example = rms(1519:1561,2);
%example = hamEx;
exLen = length(example);
currDist = 1;

for i = 1:(length(rms())-exLen)
    for j = (floor(exLen/2)):2:(exLen*2);
        step = rms(i:i+j,2);
        [Dist,D,k,w] = dtw(example',step');
        if Dist < currDist;
            currDist = Dist;
            matchLen = j;
        end
    end
    Distance(i) = currDist;
    matchLength(i) = matchLen;
    currDist = 1;
    
end

%scale error to 0 - 1
%error(:) = error()./max(error());

%% writing extension and contraction for the length of
%step

%pseudocode: 
%   for j = len(ex)/2 : len(ex)*2
%       step = data(currStart:j)
%       Dist = dtw(example,step)
%       if Dist < currDist
%           currDist = Dist
%   end

%% plot step through error matching
figure(2), hold on
tempRMS = mean(error) + rms(:,2);
plot(error,'r');
plot(tempRMS,'b');



%%
%stretching a vector X to Y length N
stretch = interp1(x,linspace(1,numel(x),N));

%% dynamic time warping 
ex3 = rms(1519:1544,2);
ex4 = rms(1474:1501,2);


%% peak detection

 %data = [2 12 4 6 9 4 3 1 19 7]; % Define data with peaks
tempdata = rms(:,2);    
 [pks,locs] = findpeaks(tempdata);       % Find peaks and their indices
 plot(tempdata,'Color','blue'); hold on;
 plot(locs,tempdata(locs),'k^','markerfacecolor',[1 0 0]);
 
 % trough detection
 
 tempdata2 = rms(:,2).* -1;
 [pks,tlocs] = findpeaks(tempdata2);    
  plot(tlocs,tempdata(tlocs),'k*','markerfacecolor',[0 1 0]);

%% building a table of examples, exploring stretching
%to be taken from rms(:,2) of hammering 1
%these are indicies of 6 examples after doing peak detection
hammEx = ...
    [1216,1225,1242,1255,1259;
     1259,1268,1286,1296,1299;
     1301,1311,1325,1339,1343;
     1343,1357,1370,1383,1386;
     1386,1394,1407,1419,1425;
     1425,1444,1456,1469,1474;]
 
 %% from main.m
 %scales the data vectors to between 1 and 0


for i = 1:numel(s)
    for j = 1:numel(ax)
        tmp = d.(s{i}).(ax{j});
        tmp = (tmp - min(tmp))./ range(tmp);
        d.(s{i}).(ax{j}) = tmp;
    end
end

clear tmp i j
    


