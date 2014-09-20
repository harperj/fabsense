function resample()
% this is just copied over code right now


%resample the data
fs = 200;
start = d.time(1);
finish = d.time(end);
tq = start:(1/fs):finish;

%%

temp = zeros(length(tq),10);
temp(:,1) = tq;

for i = 2:10
    y = d.all(:,i);
    temp(:,i) = interp1(d.time(:,1),y,tq,'linear');
end



d.all = temp;
d.time = tq';

