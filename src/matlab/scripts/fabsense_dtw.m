%% dtw 
exampleNumber = 1;
exampleSensor = 'acc';
%still need to code the conditionals for acc/gyr/mag
%this is just using accelerometer
tempX = d.ann.examples{1}(:,2);
tempY = d.ann.examples{1}(:,3);
tempZ = d.ann.examples{1}(:,4);

for i = 1:(length(d.acc.x)-length(tempX))
    %take the X component
    step = d.acc.x(i:length(tempX)+i-1);
    [dist,~,~,~] = dtw(tempX',step');
    distance(i,1) = dist;
    % y component
    step = d.acc.y(i:length(tempX)+i-1);
    [dist,~,~,~] = dtw(tempY',step');
    distance(i,2) = dist;
    % z component
    step = d.acc.z(i:length(tempX)+i-1);
    [dist,~,~,~] = dtw(tempZ',step');
    distance(i,3) = dist;
    % take the magnitude of the results of each
    distance(i,4) = rms(distance(i,1:3));
end

clear exampleNumber exampleSensor tempX tempY tempZ step dist

%% detect troughs
temp = distance(:,4).* -1;
[pks,tlocs] = findpeaks(temp);
temp  = temp .* -1;

%% threshold
threshold = 2;
temp  = temp(tlocs);
indices = find((temp > threshold));
temp(indices) = [];
tlocs(indices) = [];
plot(distance(:,4),'b');
hold on;
plot(tlocs,temp,'k*','markerfacecolor',[0 1 0]);

clear threshold i peaks indicies example

%% output to annotation interface
%length here is hard coded
len = 80;
for i = 1:length(tlocs)
    dtwOutput(i,1) = d.time(tlocs(i));
    dtwOutput(i,2) = d.time((tlocs(i)+len));
end

format long g

dlmwrite('dtw-output.csv',dtwOutput,...
    'delimiter',',','precision',12);