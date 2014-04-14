function [accuracy,predicted] = trainTest(trainNums,testNums,...
    leaveout,featurelist,dataindex)

% train a single classifier if acceptable
if ~leaveout
    % train
    [~,classifier,wordLabels] = ...
        buildClassifier(trainNums,featurelist);
    
    %and save classifier
    filename = 'classifier.mat';
    testfolder = '../../../data/test-classifier/';
    filename = [testfolder, filename];
    save(filename,'classifier');
    
    %save the word lookup
    filename = [testfolder, 'label-lookup'];
    save(filename,'wordLabels');
end

%% main testing loop
%now comes the main testing loop
accuracy = zeros(length(testNums),1);

for i = 1:length(testNums)
    if leaveout
        %train classifier
        trainNums(trainNums == testNums(i)) = [];
        [~,classifier,wordLabels] = ...
            buildClassifier(trainNums,featurelist);
    end
    
    %load the test data
    testfolder = dataindex{find(cell2mat(dataindex(:,2)) == ...
        testNums(i),1,'first'),1};
    test = loadTest(testNums(i),testfolder);
    
    %make a dummy label vector
    dummylabels = ones(size(test.features,1),1) * 10;
    
    %do the testing
    test.sparsefeatures = sparse(test.features);
    [predicted.numlabels, ~, ~] = ...
        predict(dummylabels,test.sparsefeatures,classifier,'-q');
    
    %check with the annotations
    if test.annotations
        
        %convert the predicted num labels into strings
        predicted.labels = cell(length(predicted.numlabels),1);
        acc = false(length(predicted.labels),1);
        
        for j = 1:length(predicted.numlabels)
            %returns the name associated with the number
            predicted.labels{j,1} = wordLabels{predicted.numlabels(j),1};
            
            %now check the accuracy
            acc(j) = strcmp(test.labels(j),predicted.labels(j));
        end
        
        %now check the accuracy
        accuracy(i) = sum(acc)/length(acc);
        fprintf('The classification accuracy was: %i \n', ...
            accuracy(i));
    else 
        accuracy(i) = 0;
    end
    
end   
clear labelsfile dummylabels classifierfile

%% smoothing: performs convolution to remove random labels
predicted = smoothOutput(predicted,wordLabels);

%% meaningful output!
[predicted,output] = convertOutputTime(predicted,test,wordLabels);

%% write the output
T = cell2table(output,'VariableNames',{'label','start','finish'});
filename = ['../../../data/test-classifier/',...
    num2str(testNums(i)),'-classified.csv'];
writetable(T,filename);

filename = ['../../../data/', testfolder, '/', ...
    num2str(testNums(i)),'-classified.csv'];
writetable(T,filename);
