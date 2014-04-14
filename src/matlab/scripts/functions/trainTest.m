function [accuracy,predicted,log] = trainTest(trainNums,testNums,...
    leaveout,featurelist,dataindex,winsize)

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
        temp  = trainNums;
        temp(temp == testNums(i)) = [];
        [~,classifier,wordLabels] = ...
            buildClassifier(temp,featurelist);
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
        fprintf('Classification accuracy trial %d was: %5.3f \n', ...
            testNums(i), accuracy(i)*100);
    else 
        accuracy(i) = 0;
    end
    
  
clear labelsfile dummylabels classifierfile

%% smoothing: performs convolution to remove random labels
predicted = smoothOutput(predicted,wordLabels);

%% meaningful output!
[predicted,output] = convertOutputTime(predicted,test,wordLabels);

%% write the output
if size(output,1) > 0
    T = cell2table(output,'VariableNames',{'label','start','finish'});
    filename = ['../../../data/test-classifier/outputs/',...
        num2str(testNums(i)),'-classified.csv'];
    writetable(T,filename);
    
    filename = ['../../../data/', testfolder, '/', ...
        num2str(testNums(i)),'-classified.csv'];
    writetable(T,filename);
end

%% build the log
filename = ['../../../data/', testfolder, '/', ...
    num2str(testNums(i)),'-outputlog.txt'];

if(~exist(filename,'file'))
    headerline = {'trial','accuracy','window','pass','loss','window',...
        'features','training'};
    headerformat = '%s %s %s %s %s %s %s %s \n';
    FID = fopen(filename,'a+');
    fprintf(FID,headerformat,headerline{1,:});
    fclose(FID);
    disp('crazy')
end

if leaveout
    log = {testNums(i),accuracy(i)*100,0,0,0,winsize,...
        mat2str(double(featurelist)),mat2str(temp)};
else
    log = {testNums(i),accuracy(i)*100,0,0,0,winsize,...
        mat2str(double(featurelist)),mat2str(trainNums)};
end
format = '%5d %3.3f %5d %5d %5d %5.2f %s %s \n';

%write to trial folder logs
FID = fopen(filename,'a');
fprintf(FID,format,log{1,:});
fclose(FID);

%write to main log
filename = '../../../data/test-classifier/outputlog.txt';
FID = fopen(filename,'a');
fprintf(FID,format,log{1,:});
fclose(FID);

end
end
