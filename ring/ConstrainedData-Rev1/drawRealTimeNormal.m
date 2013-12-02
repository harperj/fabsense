%% Plot real in real-world time

%EXample code.

% format long g % turns scientific notation into 
% 
% % compute sample frequency
% %timestamp(2:end) - timestamp(1:end-1) % gives 
% timest
% 
% pause(.01)
% 
% plot(t,accX,'r-',t,accY,'g-',t,accZ,'b-')

%% Clear all close all
clc
clear all;
close all;

%% load file
global data
filename = input('enter file: ','s');
data = cell2mat(struct2cell(load(filename)));

%% compute rms energy
for i = 2:10
    data(:,i) = data(:,i)/max(abs(data(:,i)));
end

for i = 1:length(data)
rms(i) = sqrt(sum(data(i,2:10).^2)/9);
end

%% build plot
global timestamp

h = figure('Color',[1 1 1]);

%figure('Color',[1 1 1]);
%acc = subplot(3,1,1);
%gyr = subplot(3,1,2);
%mag = subplot(3,1,3);

button = uicontrol('Style','togglebutton','String','Start/Stop Event',...
    'pos',[100 10 150 35],'parent',h,...
    'Min',0,'Max',1,'Value',0,...
    'Callback',@toggleState);

button2 = uicontrol('Style','togglebutton','String','Close Window',...
    'pos',[250 10 150 35],'parent',h,...
    'Value',0,...
    'Callback','close(h)');

buff_len   = 200;
plotData   = zeros(buff_len,11);
index      = 1:buff_len;
freq       = mean(data(2:end,1) - data(1:end-1,1));

if size(data,2) < 12
    data(:,12) = zeros();
end

data(:,13) = zeros();


%% plot data
hold on;

for i = 1:length(data(:,1))
    
    %check if close button has been pressed
    if get(button2,'Value')
        break
    end

    timestamp = i;
    
    %prep box data
    plotData(:,10) = [plotData(2:(buff_len/2),10) ; data(i,12); ...
        plotData((buff_len/2)+1:end,10)]; %put the value in
    boxStart = find(plotData(1:buff_len/2,10) == 1,1,'first');
    boxEnd = find(plotData(1:buff_len/2,10) == 1,1,'last');

    %clear axis
    cla;

    %plotbox
    if ~isempty(boxStart) && isempty(boxEnd)
       subplot(4,1,1), fill(...
           [boxStart boxStart buff_len/2 buff_len/2],...
           [0 .8 .8 0],'m');
       alpha(0.5);
       hold on;
    elseif ~isempty(boxStart) && ~isempty(boxEnd)
       subplot(4,1,1), fill(...
           [boxStart boxStart boxEnd boxEnd],...
           [0 .8 .8 0],'m');
       alpha(0.5);
       hold on;
    elseif isempty(boxStart) && ~isempty(boxEnd)
       subplot(4,1,1), fill(...
           [0 0 boxEnd boxEnd],...
           [0 .8 .8 0],'m');
       alpha(0.5);
       hold on;
   end 
     
    %plot ACC
    for j = 1:3
        plotData(:,j) = [plotData(2:end,j) ; data(i,j+1)];
    end
     subplot(4,1,1), plot(...
        index,plotData(:,1),'r-',...
        index,plotData(:,2),'g-',...
        index,plotData(:,3),'b-');
     
     axis([1 buff_len 0 1]);
     line([buff_len/2 buff_len/2],[0 1]);
     ylabel('Accel.');
     hold off;
      

    %plot GYRO
    for j = 4:6
        plotData(:,j) = [plotData(2:end,j) ; data(i,j+1)];
    end

    subplot(4,1,2), plot(...
        index,plotData(:,4),'r-',...
        index,plotData(:,5),'g-',...
        index,plotData(:,6),'b-');
    axis([1 buff_len -1 1]);
    line([buff_len/2 buff_len/2],[-1 1]);
    ylabel('Gyro.');

    %plot MAG
    for j = 7:9
        plotData(:,j) = [plotData(2:end,j) ; data(i,j+1)];
    end

    subplot(4,1,3), plot(...
        index,plotData(:,7),'r-',...
        index,plotData(:,8),'g-',...
        index,plotData(:,9),'b-');
    axis([1 buff_len -1 1]);
    line([buff_len/2 buff_len/2],[-1 1]);
    ylabel('Magnet.');
    
    %plot RMS
    plotData(:,11) = [plotData(2:end,11) ; data(i,11)];
    subplot(4,1,4), plot(index, plotData(:,11),'r-');
    axis([1 buff_len min(rms) 3]);
    line([buff_len/2 buff_len/2],[-4 4]);
    ylabel('RMS');
    
    
    drawnow;
    hold off;
    %pause(freq);
end

%it works!!! but with the pause it takes 1:05:00 
% and without the pause it takes 00:32:00 which is still 
% longer 

%% process trimmed data 
%takes my labelling scheme of 1 to start and event & 2 to end the
%event, relabels the column with 0s for not event, 1s for events
flag = false;
data(:,12) = zeros();

for i = 1:length(data(:,13))
    if flag
        if data(i,13) == 2
            flag = false;
        end
        data(i,12) = 1;
    elseif data(i,13) == 1
            flag = true;
        
    end
end

save(filename,'data');


disp('All done!');





