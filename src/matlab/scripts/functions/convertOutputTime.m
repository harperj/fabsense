function [predicted,output] = ...
    convertOutputTime(predicted,test,wordLabels)

class = predicted.numlabels(1,2);
start = 1;
predicted.output = [];

for i = 2:size(predicted.labels,1)
    c = predicted.numlabels(i,2);
    if c ~= class
        fin = i - 1;
        predicted.output = [predicted.output; [class, start, fin]];
        class = c;
        start = i;
    elseif i == size(predicted.labels,1)
        fin = i;
        predicted.output = [predicted.output; [class, start, fin]];
    end
end

%% test
output = [];

for i = 1:size(predicted.output,1)
    label = num2class(predicted.output(i,1),wordLabels);
    if ~strcmp(label,'noise')
        %crazy lookup to go from output to timestamp to time
        start  = test.time(test.timestamp(predicted.output(i,2),3),1);
        finish = test.time(test.timestamp(predicted.output(i,3),4),1);
        
        %build the final annotation line
        out = {label,start*1000,finish*1000};
        output = [output;out];
    end 
end