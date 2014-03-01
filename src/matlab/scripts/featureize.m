function [d] = featureize(data)
    [d1,d2,d3] = size(data);
    d = zeros(d3,d1*d2);
    for i = 1:d3;
        d(i,:) = reshape(data(:,:,i),1,d1*d2);
    end
    d = sparse(d);

end