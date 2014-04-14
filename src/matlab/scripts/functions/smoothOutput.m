function [predicted] = smoothOutput(predicted,wordLabels)

predicted.classlabels = zeros(length(predicted.numlabels),4);
numClasses = size(wordLabels,1);

for i  = 1:numClasses
    predicted.classlabels(:,i) = (predicted.numlabels(:,1) == i);
    predicted.classlabels(:,(numClasses+i)) = ...
        conv(predicted.classlabels(:,i),[1,1,1,1,1],'same');
end

[~,I] = max(predicted.classlabels(:,numClasses+1:end),[],2);
predicted.labels(:,2)    = num2class(I,wordLabels);
predicted.numlabels(:,2) = I;

end
