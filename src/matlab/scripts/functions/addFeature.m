function [] = addFeature(data,name)
%{
Intention of this feature is to take a vector of features and correctly add
it to the end of the feacture matrix and add a label to the
data.featurename row
%}
if ~ischar(name)
    error('feature name must be a string');
else if 
end

%appends a feature to the end of featurenames 
d.featurename = {d.featurename, name};



end



