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