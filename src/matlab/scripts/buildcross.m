function [train, test] = buildcross(data,fold)
    %this is hard coded to the number of folds
    %and the training set size
    start = fold*102 - 101;
    fin   = fold*102; 
    test  = data(start:fin,:);
    if fold == 1
      train = data(103:end,:);
    elseif fold == 6
        train = data(1:534,:);
    else
        train = [data(1:start-1,:);data(fin+1:end,:)];
    end
end