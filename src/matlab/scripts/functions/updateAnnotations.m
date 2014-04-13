function updateAnnotations(trialnums,dataindex)

for i = 1:length(trialnums)
    testfolder = dataindex{find(cell2mat(dataindex(:,2)) == ...
        trialnums(i),1,'first'),1};
    filename = ['../../../data/', testfolder, '/', ...
    num2str(trialnums(i)),'-annotations.csv'];
    
    disp(trialnums(i))
    if(exist(filename,'file'))
        a = importdata(filename,',');
        T = cell2table([a.textdata,num2cell(a.data)],...
            'VariableNames',{'label','start','finish'});

        writetable(T,filename);
    end
end
