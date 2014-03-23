function [train, test] = buildcross(data,fold,folds)
% needs comment, but it works!
    interval = floor(length(data)/folds);
    start = interval*(fold-1)+1;
    fin   = fold*interval; 
    test  = data(start:fin,:);
    if fold == 1
      train = data((interval+1):end,:);
    elseif fold == folds
        train = data(1:(interval*(folds-1)),:);
    else
        train = [data(1:start-1,:);data(fin+1:end,:)];
    end
    
end