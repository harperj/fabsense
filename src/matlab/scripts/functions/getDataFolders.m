%% requires you start in the /src/matlab/scripts folder
%cd Documents/Research/fabsense/src/matlab/scripts/

function dataIndex = getDataFolders()
D = dir('../../../data/*-*');
dataIndex = cell(size(D,1),1);


for i = 1:size(D,1)
    C = strsplit(D(i).name,'-');
    [x,ok] = str2num(C{1});
    if ok 
       dataIndex{i,1} = D(i).name;
       dataIndex{i,2} = x;
    end
end
dataIndex(end-2:end,:) = [];
end
